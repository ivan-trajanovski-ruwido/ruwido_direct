class RcuInformation {
  final String? modelNumber;
  final String? versionString;
  final String? macAddress;
  final int? version;
  final int? randomNumber;

  static const RcuInformation empty = RcuInformation._createEmpty();

  RcuInformation(this.modelNumber, this.versionString, this.macAddress, this.version, this.randomNumber);

  const RcuInformation._createEmpty()
      : modelNumber = null,
        versionString = null,
        macAddress = null,
        version = null,
        randomNumber = null;

  @override
  String toString() {
    return "{modelNumber: $modelNumber, versionString: $versionString,"
        " macAddress: $macAddress, version: $version,"
        " randomNumber: $randomNumber}";
  }
}
