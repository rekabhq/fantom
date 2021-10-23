enum DType { object, array, string, number, integer, boolean }

class Component {
  final String fileContent;
  final MetaData metaData;

  Component({
    required this.fileContent,
    required this.metaData,
  });
}

class MetaData {}
