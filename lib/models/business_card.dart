import 'package:hive_ce/hive.dart';

class BusinessCard {
  BusinessCard({
    required this.id,
    required this.cardName,
    this.fullName = '',
    this.jobTitle = '',
    this.company = '',
    this.email = '',
    this.phone = '',
    this.website = '',
    this.address = '',
    this.linkedin = '',
    this.twitter = '',
    this.instagram = '',
    this.notes = '',
    this.photoPath,
    this.primaryColor = 0xFF1F6FEB,
    this.templateId = 'modern',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final String id;
  String cardName;
  String fullName;
  String jobTitle;
  String company;
  String email;
  String phone;
  String website;
  String address;
  String linkedin;
  String twitter;
  String instagram;
  String notes;
  String? photoPath;
  int primaryColor;
  String templateId;
  DateTime createdAt;
  DateTime updatedAt;

  BusinessCard copyWith({
    String? cardName,
    String? fullName,
    String? jobTitle,
    String? company,
    String? email,
    String? phone,
    String? website,
    String? address,
    String? linkedin,
    String? twitter,
    String? instagram,
    String? notes,
    String? photoPath,
    int? primaryColor,
    String? templateId,
  }) {
    return BusinessCard(
      id: id,
      cardName: cardName ?? this.cardName,
      fullName: fullName ?? this.fullName,
      jobTitle: jobTitle ?? this.jobTitle,
      company: company ?? this.company,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      address: address ?? this.address,
      linkedin: linkedin ?? this.linkedin,
      twitter: twitter ?? this.twitter,
      instagram: instagram ?? this.instagram,
      notes: notes ?? this.notes,
      photoPath: photoPath ?? this.photoPath,
      primaryColor: primaryColor ?? this.primaryColor,
      templateId: templateId ?? this.templateId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'cardName': cardName,
        'fullName': fullName,
        'jobTitle': jobTitle,
        'company': company,
        'email': email,
        'phone': phone,
        'website': website,
        'address': address,
        'linkedin': linkedin,
        'twitter': twitter,
        'instagram': instagram,
        'notes': notes,
        'photoPath': photoPath,
        'primaryColor': primaryColor,
        'templateId': templateId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  static BusinessCard fromJson(Map<String, dynamic> json) => BusinessCard(
        id: json['id'] as String,
        cardName: json['cardName'] as String? ?? '',
        fullName: json['fullName'] as String? ?? '',
        jobTitle: json['jobTitle'] as String? ?? '',
        company: json['company'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        website: json['website'] as String? ?? '',
        address: json['address'] as String? ?? '',
        linkedin: json['linkedin'] as String? ?? '',
        twitter: json['twitter'] as String? ?? '',
        instagram: json['instagram'] as String? ?? '',
        notes: json['notes'] as String? ?? '',
        photoPath: json['photoPath'] as String?,
        primaryColor: json['primaryColor'] as int? ?? 0xFF1F6FEB,
        templateId: json['templateId'] as String? ?? 'modern',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
      );
}

class BusinessCardAdapter extends TypeAdapter<BusinessCard> {
  @override
  final int typeId = 1;

  @override
  BusinessCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BusinessCard(
      id: fields[0] as String,
      cardName: fields[1] as String,
      fullName: fields[2] as String? ?? '',
      jobTitle: fields[3] as String? ?? '',
      company: fields[4] as String? ?? '',
      email: fields[5] as String? ?? '',
      phone: fields[6] as String? ?? '',
      website: fields[7] as String? ?? '',
      address: fields[8] as String? ?? '',
      linkedin: fields[9] as String? ?? '',
      twitter: fields[10] as String? ?? '',
      instagram: fields[11] as String? ?? '',
      notes: fields[12] as String? ?? '',
      photoPath: fields[13] as String?,
      primaryColor: fields[14] as int? ?? 0xFF1F6FEB,
      templateId: fields[15] as String? ?? 'modern',
      createdAt: fields[16] as DateTime?,
      updatedAt: fields[17] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, BusinessCard obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.cardName)
      ..writeByte(2)
      ..write(obj.fullName)
      ..writeByte(3)
      ..write(obj.jobTitle)
      ..writeByte(4)
      ..write(obj.company)
      ..writeByte(5)
      ..write(obj.email)
      ..writeByte(6)
      ..write(obj.phone)
      ..writeByte(7)
      ..write(obj.website)
      ..writeByte(8)
      ..write(obj.address)
      ..writeByte(9)
      ..write(obj.linkedin)
      ..writeByte(10)
      ..write(obj.twitter)
      ..writeByte(11)
      ..write(obj.instagram)
      ..writeByte(12)
      ..write(obj.notes)
      ..writeByte(13)
      ..write(obj.photoPath)
      ..writeByte(14)
      ..write(obj.primaryColor)
      ..writeByte(15)
      ..write(obj.templateId)
      ..writeByte(16)
      ..write(obj.createdAt)
      ..writeByte(17)
      ..write(obj.updatedAt);
  }
}
