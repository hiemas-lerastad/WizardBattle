class_name VOIPManager;
extends Node;

@export_group("Nodes")
@export var input: AudioStreamPlayer3D;
@export var outputs: Array[AudioStreamPlayer3D];
@export_subgroup("Command Recogniser")
@export var voice_command_recogniser: VoiceCommandRecogniser;

@export_group("Settings")
@export var enabled: bool = true;
@export var buffer_size: int = 1024;
@export var bus_name: String = "Record";
@export var effect_id: int = 0;
@export var microphone_input: bool = true;
@export_subgroup("Command Recogniser")
@export var analyser_effect_id: int = 1;
@export var num_bands: int = 20;
@export var min_frequency: int = 80;
@export var max_frequency: int = 4000;

var idx: int;
var effect: AudioEffect;
var playbacks: Array[AudioStreamGeneratorPlayback];
var analyser: AudioEffectSpectrumAnalyzerInstance;

signal voice_command;


func _unhandled_input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event.is_action_pressed("record_fireball"):
			voice_command_recogniser.record_template("fireball");

		if event.is_action_pressed("record_icespike"):
			voice_command_recogniser.record_template("iceshard");

		if event.is_action_pressed("record_magic_missile"):
			voice_command_recogniser.record_template("magicmissile");


func _ready() -> void:
	if is_multiplayer_authority():
		if microphone_input:
			input.stream = AudioStreamMicrophone.new();
			input.play();

		idx = AudioServer.get_bus_index(bus_name);
		effect = AudioServer.get_bus_effect(idx, effect_id);

		if voice_command_recogniser:
			voice_command_recogniser.connect("fire_command", handle_voice_command);

		if AudioServer.get_bus_effect(idx, analyser_effect_id):
			analyser = AudioServer.get_bus_effect_instance(idx, analyser_effect_id) as AudioEffectSpectrumAnalyzerInstance;

	for output in outputs:
		output.play()

		playbacks.append(output.get_stream_playback());


func handle_voice_command(command: String) -> void:
	voice_command.emit(command);

func get_band_magnitudes() -> PackedFloat32Array:
	var mags := PackedFloat32Array()

	if not analyser:
		return mags

	var band_width = float(max_frequency - min_frequency) / num_bands

	for i in range(num_bands):
		var f1 = min_frequency + i * band_width
		var f2 = f1 + band_width
		var v: Vector2 = analyser.get_magnitude_for_frequency_range(f1, f2)
		mags.append(0.5 * (v.x + v.y))

	return mags


func _process(_delta: float) -> void:
	if not is_multiplayer_authority() or not enabled: return;

	buffer_size = effect.get_frames_available();

	if effect.can_get_buffer(buffer_size):
		if analyser and voice_command_recogniser:
			var mags: PackedFloat32Array = get_band_magnitudes();
			if mags.size() > 0:
				voice_command_recogniser.add_spectrum_frame(mags);

		send_data.rpc(effect.get_buffer(buffer_size));

	effect.clear_buffer();


@rpc("any_peer", "call_remote", "reliable")
func send_data(data : PackedVector2Array):
	for playback in playbacks:
		for i in range(0, data.size()):
			playback.push_frame(data[i]);
