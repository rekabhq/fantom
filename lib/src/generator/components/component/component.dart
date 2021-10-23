enum DType { object, array, string, number, integer, boolean }

/// is just a meta-data class that contains the content of the file that is generated for the an openapi component
/// and also a meta-data about what is in the genrated file so that it can be used later by other sections of
/// our [Generator] service
class GeneratedComponent {
  final String fileContent;
  final MetaData metaData;

  GeneratedComponent({
    required this.fileContent,
    required this.metaData,
  });
}

class MetaData {}
