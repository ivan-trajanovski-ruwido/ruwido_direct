import 'package:fimber/fimber.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:ruwido_direct_riverpod/services/rcu/rcu_information.dart';
import 'package:ruwido_direct_riverpod/services/rcu/rcu_information_builder.dart';

class ManufacturerDataRuwidoParser {
  static RcuInformation parse(List<int>? manufacturerData) {
    RcuInformationBuilder rcuInformation = RcuInformationBuilder();

    if (manufacturerData == null) {
      // Log or handle the case where manufacturerData is not available
      return rcuInformation.build();
    }

    var byteData = ByteData.sublistView(Uint8List.fromList(manufacturerData));
    var readBuffer = ReadBuffer(byteData);

    var fullLen = readBuffer.data.lengthInBytes;
    while (readBuffer.hasRemaining) {
      int partLength = readBuffer.getUint8() - 1;
      if (partLength > fullLen) {
        // Log or handle error
        break;
      }
      fullLen -= partLength;

      int partType = readBuffer.getUint8();
      var data = readBuffer.getUint8List(partLength);

      switch (partType) {
        case 1:
          _parseModel(data, rcuInformation);
          break;
        case 2:
          _parseRandomNumber(data, rcuInformation);
          break;
        case 3:
          _parseVersion(data, rcuInformation);
          break;
        case 4:
          _parseMacAddress(data, rcuInformation);
          break;
        case 5:
          // Handle bond state if necessary
          break;
        default:
        // Log or handle unhandled type
      }
    }

    return rcuInformation.build();
  }

  static _parseModel(Uint8List data, RcuInformationBuilder rcuInformation) {
    if (data.length != 4) {
      return;
    }

    var byteData = ByteData.sublistView(data);
    int major = byteData.getUint16(0, Endian.little);
    String majorString = NumberFormat("0000").format(major);

    int minor = byteData.getUint16(2, Endian.little);
    String minorString = NumberFormat("000").format(minor);

    rcuInformation.modelNumber = "$majorString-$minorString";
  }

  static _parseRandomNumber(Uint8List data, RcuInformationBuilder rcuInformation) {
    if (data.length != 1) {
      return;
    }

    var byteData = ByteData.sublistView(data);
    rcuInformation.randomNumber = byteData.getUint8(0);
  }

  static _parseVersion(Uint8List data, RcuInformationBuilder rcuInformation) {
    if (data.length != 4) {
      return;
    }

    var byteData = ByteData.sublistView(data);
    int major = byteData.getUint8(0);
    int minor = byteData.getUint8(1);
    int micro = byteData.getUint16(2, Endian.little);

    rcuInformation.version = major << 24 | minor << 16 | micro;
    rcuInformation.versionString = "$major.$minor.$micro";

    Fimber.d("version: ${rcuInformation.versionString}");
  }

  static _parseMacAddress(Uint8List data, RcuInformationBuilder rcuInformation) {
    if (data.length != 4) {
      return;
    }

    List<String> entries = [];

    var byteData = ByteData.sublistView(data);
    for (int i = 0; i < 6; i++) {
      entries.add(byteData.getUint8(i).toRadixString(16).padLeft(2, '0'));
    }

    return entries.join(":");
  }
}
