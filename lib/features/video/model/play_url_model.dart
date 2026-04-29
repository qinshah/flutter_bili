class PlayUrlModel {
  PlayUrlModel({
    this.quality,
    this.timeLength,
    this.acceptFormat,
    this.acceptDesc,
    this.acceptQuality,
    this.videoCodecid,
    this.dash,
    this.supportFormats,
  });

  int? quality;
  int? timeLength;
  String? acceptFormat;
  List<dynamic>? acceptDesc;
  List<int>? acceptQuality;
  int? videoCodecid;
  Dash? dash;
  List<FormatItem>? supportFormats;

  factory PlayUrlModel.fromJson(Map<String, dynamic> json) {
    return PlayUrlModel(
      quality: json['quality'],
      timeLength: json['timelength'],
      acceptFormat: json['accept_format'],
      acceptDesc: json['accept_description'],
      acceptQuality:
          (json['accept_quality'] as List?)?.map<int>((e) => e as int).toList(),
      videoCodecid: json['video_codecid'],
      dash: json['dash'] != null ? Dash.fromJson(json['dash']) : null,
      supportFormats: (json['support_formats'] as List?)
          ?.map<FormatItem>((e) => FormatItem.fromJson(e))
          .toList(),
    );
  }
}

class Dash {
  Dash({
    this.duration,
    this.minBufferTime,
    this.video,
    this.audio,
  });

  int? duration;
  double? minBufferTime;
  List<VideoItem>? video;
  List<AudioItem>? audio;

  factory Dash.fromJson(Map<String, dynamic> json) {
    final List<AudioItem> audioList = (json['audio'] as List?)
            ?.map<AudioItem>((e) => AudioItem.fromJson(e))
            .toList() ??
        [];

    // Insert Dolby audio at the front if present
    if (json['dolby']?['audio'] case List dolbyList) {
      audioList.insertAll(
        0,
        dolbyList.map((e) => AudioItem.fromJson(e)),
      );
    }

    // Insert FLAC audio at the front if present
    final flacAudio = json['flac']?['audio'];
    if (flacAudio != null) {
      audioList.insert(0, AudioItem.fromJson(flacAudio));
    }

    return Dash(
      duration: json['duration'],
      minBufferTime: (json['minBufferTime'] as num?)?.toDouble(),
      video: (json['video'] as List?)
          ?.map<VideoItem>((e) => VideoItem.fromJson(e))
          .toList(),
      audio: audioList.isEmpty ? null : audioList,
    );
  }
}

class VideoItem {
  VideoItem({
    this.id,
    this.baseUrl,
    this.backupUrl,
    this.bandwidth,
    this.codecid,
    this.mimeType,
    this.codecs,
    this.width,
    this.height,
    this.frameRate,
  });

  /// Quality code: 116=1080P60, 80=1080P, 64=720P, 32=480P, 16=360P
  int? id;
  String? baseUrl;
  List<String>? backupUrl;
  int? bandwidth;
  int? codecid;
  String? mimeType;
  String? codecs;
  int? width;
  int? height;
  String? frameRate;

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      id: json['id'],
      baseUrl: json['baseUrl'] ?? json['base_url'],
      backupUrl: ((json['backupUrl'] ?? json['backup_url']) as List?)
          ?.map<String>((e) => e as String)
          .toList(),
      bandwidth: json['bandWidth'] ?? json['bandwidth'],
      codecid: json['codecid'],
      mimeType: json['mime_type'],
      codecs: json['codecs'],
      width: json['width'],
      height: json['height'],
      frameRate: json['frameRate'] ?? json['frame_rate'],
    );
  }

  /// All available play URLs (base first, then backups)
  Iterable<String> get playUrls sync* {
    if (baseUrl?.isNotEmpty == true) yield baseUrl!;
    if (backupUrl?.isNotEmpty == true) yield* backupUrl!;
  }
}

class AudioItem {
  AudioItem({
    this.id,
    this.baseUrl,
    this.backupUrl,
    this.bandwidth,
    this.mimeType,
    this.codecs,
  });

  int? id;
  String? baseUrl;
  List<String>? backupUrl;
  int? bandwidth;
  String? mimeType;
  String? codecs;

  factory AudioItem.fromJson(Map<String, dynamic> json) {
    return AudioItem(
      id: json['id'],
      baseUrl: json['baseUrl'] ?? json['base_url'],
      backupUrl: ((json['backupUrl'] ?? json['backup_url']) as List?)
          ?.map<String>((e) => e as String)
          .toList(),
      bandwidth: json['bandWidth'] ?? json['bandwidth'],
      mimeType: json['mime_type'],
      codecs: json['codecs'],
    );
  }

  /// All available play URLs (base first, then backups)
  Iterable<String> get playUrls sync* {
    if (baseUrl?.isNotEmpty == true) yield baseUrl!;
    if (backupUrl?.isNotEmpty == true) yield* backupUrl!;
  }
}

class FormatItem {
  FormatItem({
    this.quality,
    this.format,
    this.newDesc,
    this.displayDesc,
    this.codecs,
  });

  int? quality;
  String? format;
  String? newDesc;
  String? displayDesc;
  List<String>? codecs;

  factory FormatItem.fromJson(Map<String, dynamic> json) {
    return FormatItem(
      quality: json['quality'],
      format: json['format'],
      newDesc: json['new_description'],
      displayDesc: json['display_desc'],
      codecs: (json['codecs'] as List?)?.map<String>((e) => e as String).toList(),
    );
  }
}
