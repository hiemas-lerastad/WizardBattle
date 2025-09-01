class_name VoiceCommandRecogniser;
extends Node;

@export_group("Settings")
@export var num_bands: int = 20;
@export var frame_interval: float = 0.05;
@export var max_utterance_frames: int = 40;
@export var min_utterance_frames: int = 6;
@export var energy_threshold: float = 0.002;
@export var early_exit: bool = true;
@export var max_templates_per_command: int = 5;
@export var command_cooldown: float = 0.8;
@export var global_recognition_threshold: float = 5.0;
@export var confidence_threshold: float = 1.0;

signal fire_command;

var commands: Array[String] = ["fireball", "iceshard", "magicmissile"];

var rolling_buffer: Array = [];
var candidate_frames: Array = [];
var capturing: bool = true;
var templates: Dictionary = {
	"fireball": [],
	"iceshard": [],
	"magicmissile": []
};

var command_stats: Dictionary = {
	"fireball": {"mean": 0.0, "variance": 0.0},
	"iceshard": {"mean": 0.0, "variance": 0.0},
	"magicmissile": {"mean": 0.0, "variance": 0.0}
};

var awaiting_template: String = "";
var last_command: String = "";
var last_command_time: float = 0.0;
var current_time: float = 0.0;


func _normalize(frame: PackedFloat32Array) -> PackedFloat32Array:
	var out: PackedFloat32Array = frame.duplicate();
	var norm: float = 0.0;

	for v in out:
		norm += v * v;
	
	norm = sqrt(norm);

	if norm > 0.0:
		for i in range(out.size()):
			out[i] /= norm;

	return out;


func _euclidean(a: PackedFloat32Array, b: PackedFloat32Array) -> float:
	var s: float = 0.0;

	for i in range(min(a.size(), b.size())):
		var d: float = a[i] - b[i];
		s += d * d;

	return sqrt(s);


func _dtw(seq_a: Array, seq_b: Array, best_so_far: float= INF) -> float:
	var n: int = seq_a.size();
	var m: int = seq_b.size();

	if n == 0 or m == 0:
		return INF;

	var prev: PackedFloat32Array= PackedFloat32Array();
	var curr: PackedFloat32Array = PackedFloat32Array();

	prev.resize(m + 1);
	curr.resize(m + 1);

	for j in range(m + 1):
		prev[j] = INF;

	prev[0] = 0.0;

	for i in range(1, n + 1):
		curr[0] = INF;
		var row_min: int = int(INF);

		for j in range(1, m + 1):
			var cost: float = _euclidean(_normalize(seq_a[i - 1]), _normalize(seq_b[j - 1]));
			var best: float = min(prev[j], curr[j - 1], prev[j - 1]);

			curr[j] = cost + best;
			row_min = min(row_min, curr[j]);

		if early_exit and row_min > best_so_far:
			return row_min;

		for j in range(m + 1):
			prev[j] = curr[j];

	return prev[m];


func _physics_process(delta: float) -> void:
	current_time += delta;


func add_spectrum_frame(frame: PackedFloat32Array) -> void:
	rolling_buffer.append(frame);

	if rolling_buffer.size() > max_utterance_frames:
		rolling_buffer.remove_at(0);

	var energy: float = 0.0;

	for v in frame:
		energy += v;

	energy /= max(1, frame.size());

	var in_speech: bool = energy >= energy_threshold;

	if in_speech:
		if not capturing:
			capturing = true;
			candidate_frames.clear();

		candidate_frames.append(frame);

		if candidate_frames.size() > max_utterance_frames:
			candidate_frames.remove_at(0);

	elif capturing:
		capturing = false;

		if candidate_frames.size() >= min_utterance_frames:
			var cmd: String = _recognize(candidate_frames);

			if cmd != "":
				if cmd != last_command or (current_time - last_command_time >= command_cooldown):
					_handle_command(cmd);
					last_command = cmd;
					last_command_time = current_time;

		candidate_frames.clear();


func _handle_command(cmd: String) -> void:
	print("[VoiceCommand] Recognized command:", cmd);
	fire_command.emit(cmd);

func record_template(cmd: String) -> void:
	capturing = true;
	candidate_frames.clear();
	awaiting_template = cmd;
	print("[VoiceCommand] Awaiting template for '%s'" % cmd);

func _store_template(cmd: String, seq: Array) -> void:
	var arr: Array = templates.get(cmd, []);
	arr.append(seq);

	if arr.size() > max_templates_per_command:
		arr = arr.slice(arr.size() - max_templates_per_command, max_templates_per_command);

	templates[cmd] = arr;

	_update_command_stats(cmd);


func _update_command_stats(cmd: String) -> void:
	var tmpl_list: Array = templates[cmd];
	if tmpl_list.is_empty():
		return;

	var distances: Array = [];

	for i in range(tmpl_list.size()):
		for j in range(i+1, tmpl_list.size()):
			distances.append(_dtw(tmpl_list[i], tmpl_list[j]));

	if distances.is_empty():
		return;

	var mean: float = 0.0;

	for d in distances:
		mean += d;

	mean /= distances.size();

	var variance: float = 0.0;

	for d in distances:
		variance += (d - mean)*(d - mean);

	variance /= distances.size();
	command_stats[cmd] = {"mean": mean, "variance": variance};


func _recognize(seq: Array) -> String:
	if awaiting_template != "":
		_store_template(awaiting_template, seq.duplicate());
		awaiting_template = "";
		print("[VoiceCommand] Stored template for command");
		return "";

	var scores: Dictionary = {}

	for cmd in commands:
		var tmpl_list: Array = templates[cmd];
		if tmpl_list.is_empty():
			continue;

		var sum: float = 0.0;

		for tmpl in tmpl_list:
			sum += _dtw(seq, tmpl);

		scores[cmd] = sum / tmpl_list.size();

	if scores.is_empty():
		return "";

	var sorted: Array= scores.keys();

	sorted.sort_custom(func(a, b): return scores[a] < scores[b]);

	var best_cmd: String = sorted[0];
	var best_score: float = scores[best_cmd];

	if scores.size() == 1:
		if best_score < global_recognition_threshold:
			return best_cmd;

		return "";

	var second_score: float = scores[sorted[1]];
	var confidence: float = second_score / max(best_score, 0.0001);

	var stats: Dictionary = command_stats.get(best_cmd, {"mean": best_score, "variance": 0.0});
	var threshold: float = stats.mean + 2.0 * sqrt(stats.variance);
	if threshold <= 0.0:
		threshold = global_recognition_threshold

	if best_score < threshold and confidence > confidence_threshold:
		return best_cmd;

	return "";
