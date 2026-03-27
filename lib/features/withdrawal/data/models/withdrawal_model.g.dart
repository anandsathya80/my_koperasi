// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'withdrawal_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WithdrawalAdapter extends TypeAdapter<Withdrawal> {
  @override
  final int typeId = 2;

  @override
  Withdrawal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Withdrawal(
      id: fields[0] as String,
      memberId: fields[1] as String,
      amount: fields[2] as double,
      note: fields[3] as String,
      date: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Withdrawal obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.memberId)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.note)
      ..writeByte(4)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WithdrawalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
