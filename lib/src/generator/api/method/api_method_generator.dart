import 'package:fantom/src/generator/api/api_constants.dart';
import 'package:fantom/src/generator/api/method/body_parser.dart';
import 'package:fantom/src/generator/api/method/params_parser.dart';
import 'package:fantom/src/generator/api/method/response_parser.dart';
import 'package:fantom/src/generator/components/component/generated_components.dart';
import 'package:fantom/src/generator/name/name_generator.dart';
import 'package:fantom/src/generator/name/utils.dart';
import 'package:fantom/src/generator/schema/schema_default_value_generator.dart';
import 'package:fantom/src/mediator/model/schema/schema_model.dart';
import 'package:fantom/src/reader/model/model.dart';
import 'package:recase/recase.dart';

// TODO: add test for this class
class ApiMethodGenerator {
  final OpenApi openApi;
  final SchemaDefaultValueGenerator defaultValueGenerator;
  final MethodParamsParser methodParamsParser;
  final MethodBodyParser methodBodyParser;
  final MethodResponseParser methodResponseParser;
  final NameGenerator nameGenerator;

  final bool useResult;

  ApiMethodGenerator({
    required this.openApi,
    required this.defaultValueGenerator,
    required this.methodParamsParser,
    required this.methodBodyParser,
    required this.methodResponseParser,
    required this.nameGenerator,
    this.useResult = true,
  });

  String generateMethods() {
    if (openApi.paths.paths.isEmpty) return '';

    // buffer to store generated data
    final buffer = StringBuffer();

    // iterating over paths
    for (final path in openApi.paths.paths.entries) {
      final pathParams = path.value.parameters;

      final pathGeneratedComponentParams = pathParams
          ?.map(
            (param) => methodParamsParser.getGeneratedParameterComponent(
              path.key.pascalCase,
              param,
            ),
          )
          .toList();

      // generating doc comments for paths
      if (path.value.operations.isNotEmpty) {
        final pathValue = '"${path.key}"';
        final pathLength = pathValue.length;

        final paddingLength = 76 - pathLength;

        final paddingValue =
            paddingLength > 0 ? '-' * (paddingLength ~/ 2) : '';

        final result = '  //$paddingValue$pathValue$paddingValue';
        buffer.writeln(result.length == 80 ? result : result + '-');
        buffer.writeln();
        buffer.writeln();
      }

      // iterating over operations of the path
      for (final operation in path.value.operations.entries) {
        final operationDetail = OperationDetail(
          path: path.key,
          operationType: operation.key,
          operationId: operation.value.operationId,
        );

        final methodName = nameGenerator.generateMethodName(operationDetail);

        buffer.writeln(
          _generateOperation(
            path.key,
            methodName,
            operation,
            pathGeneratedComponentParams,
          ),
        );
      }
    }

    return buffer.toString();
  }

  String _generateOperation(
    String pathUrl,
    String methodName,
    MapEntry<String, Operation> operation,
    List<GeneratedParameterComponent>? pathParameterComponents,
  ) {
    final operationParamComponents = operation.value.parameters == null
        ? null
        : methodParamsParser.parseParams(
            operation.value.parameters!,
            methodName,
            pathParameterComponents: pathParameterComponents,
          );

    final operationBodyComponent = operation.value.requestBody == null
        ? null
        : methodBodyParser.parseRequestBody(
            operation.value.requestBody!,
            methodName,
          );

    final methodHasParameter =
        (operationParamComponents?.isNotEmpty ?? false) ||
            operationBodyComponent != null;

    final operationResponsesComponents = methodResponseParser.parseResponses(
      operation.value.responses,
      methodName,
    );

    final responseType =
        operationResponsesComponents.contentManifest?.manifest.name ??
            dioResponseType;

    final StringBuffer buffer = StringBuffer();

    // Steps:
    // -------
    // 1. generate method return type
    // ->"Future"<- methodName(params)
    // 2. generate method name
    // Future ->"methodName"<- (params)
    // 3. generate method parameters
    // Future methodName ->"(params)"<-

    buffer.writeln(_generateMethodComment(methodName, operation.key));

    buffer.writeln(
      _generateMethodSyntax(methodName, responseType),
    );

    if (methodHasParameter) {
      if (operationParamComponents != null) {
        buffer.writeln(_generateParameters(operationParamComponents));
      }
      if (operationBodyComponent != null) {
        buffer.writeln(_generateRequestBody(operationBodyComponent));
      }
    }

    buffer.writeln(_generateContentTypeParameters());

    buffer.writeln(_generateResponseContentTypeParameters());

    buffer.writeln(_generateEndMethodSyntax());

    buffer.writeln(_generateContentTypeValue(
      operationBodyComponent != null,
      operationBodyComponent?.source.isRequired,
    ));

    // -------
    // 4. generate parsed path - get paths from params and parse them
    // final path = '/user/{id}';
    buffer.writeln(_generatePathUrl(pathUrl));

    final generatedPathParams = operationParamComponents
        ?.where((param) => param.source.location == methodPathParam)
        .toList();

    // 5. generate query parameters
    final generatedQueryParams = operationParamComponents
        ?.where((param) => param.source.location == methodQueryParam)
        .toList();

    if (generatedPathParams != null || generatedQueryParams != null) {
      buffer.writeln(
        _generatePathParamParser(generatedPathParams, generatedQueryParams),
      );
    }

    // 6. generate header parameters
    final generatedHeaderParams = operationParamComponents
        ?.where((param) => param.source.location == methodHeaderParam)
        .toList();

    // final headerParams = {'accept': 'json'};
    if (generatedHeaderParams?.isNotEmpty ?? false) {
      buffer.writeln(_generateParsedHeaderParameters(generatedHeaderParams));
    }

    // 7. generate body parameters
    // final bodyJson = body.toJson();
    if (operationBodyComponent?.contentManifest != null) {
      buffer.writeln(_generateInitialBody(operationBodyComponent!));
    }

    // -------
    // 8. create request option for headers and content type
    // final option =  Options(
    //  method: POSt,
    //  headers : headerParams,
    //  contentType : contentType,
    // );
    buffer.writeln(
      _generateRequestOptions(
        operation.key,
        generatedHeaderParams,
      ),
    );

    // 9. generate request
    // final response = await dio.request(
    //  parsedPath,
    //  options: option,
    //  data: bodyJson,
    // );
    // 10. generate evaluated response
    // we should think about this
    // we should deserialize response.data to Generated response component type
    // return evaluateResponse(response);
    if (useResult) {
      buffer.writeln(
        _generateDioRequestWithResult(
          responseType,
          generatedQueryParams,
          operationBodyComponent,
        ),
      );
    } else {
      buffer.writeln(
        _generateDioRequestWithoutResult(
          responseType,
          generatedQueryParams,
          operationBodyComponent,
        ),
      );
    }
    // -------

    buffer.writeln('}');

    return buffer.toString();
  }

  String _generateMethodComment(String name, String type) =>
      '/// $name - $type method';

  String _generateContentTypeParameters() => 'String? $contentTypeVariable,';

  String _generateResponseContentTypeParameters() =>
      'String? $responseContentTypeVariable,';

  String _generateMethodSyntax(String methodName, String returnType) =>
      useResult
          ? 'Future<$resultType<$returnType, Exception>> $methodName({'
          : 'Future<$returnType> $methodName({';

  String _generateEndMethodSyntax() => '}) async {';

  String _generateContentTypeValue(bool hasBody, [bool? isRequired = false]) {
    final buffer = StringBuffer();

    buffer.write('$contentTypeVariable = $contentTypeVariable ');

    if (hasBody) {
      buffer.write(
          ' ?? $bodyVarName${isRequired == true ? '' : nullableCharacter}.$contentTypeVariable ');
    }

    if (!hasBody || isRequired != true) {
      buffer.write(' ?? $dioInstance.$dioOptions.$contentTypeVariable ');
    }

    buffer.writeln(';');

    return buffer.toString();
  }

  String _generateParameters(
    List<GeneratedParameterComponent> methodParams,
  ) {
    final StringBuffer buffer = StringBuffer();

    for (final param in methodParams) {
      final type = (param.isSchema
              ? param.schemaComponent?.dataElement.type
              : param.contentManifest?.manifest.name) ??
          dynamicType;

      final name = param.source.name;
      final isRequired = param.source.isRequired == true;

      // TODO: should we use Option<T> ?
      // TODO(amirreza): can your review this method?
      final defaultValue = (param.schemaComponent != null && !isRequired)
          ? defaultValueGenerator
              .generateOrNull(param.schemaComponent!.dataElement)
          : null;

      final isNullable = param.isNullable &&
          type != dynamicType &&
          !type.endsWith(nullableCharacter);

      /// should we use '?' or ''
      final nullableValue = isNullable || (!isRequired && defaultValue == null)
          ? nullableCharacter
          : '';

      buffer
          .write('${isRequired ? requiredType : ''} $type$nullableValue $name');

      // TODO: test default values
      buffer.writeln(
        defaultValue?.isNotEmpty == true ? '= $defaultValue ,' : ',',
      );
    }

    return buffer.toString();
  }

  String _generateRequestBody(
    GeneratedRequestBodyComponent requestBody,
  ) {
    final type = requestBody.contentManifest?.manifest.name ?? dynamicType;

    final isRequired = requestBody.source.isRequired == true;

    final isNullable =
        !isRequired && type != dynamicType && !type.endsWith(nullableCharacter);

    final nullableChar = isNullable ? nullableCharacter : '';

    return '${isRequired ? 'required' : ''} $type$nullableChar $bodyVarName,';
  }

  String _generatePathUrl(String pathUrl) =>
      'String $pathVarName = \'$pathUrl\';';

  // TODO: Test all situations in path and query params
  String _generatePathParamParser(
    List<GeneratedParameterComponent>? generatedPathParams,
    List<GeneratedParameterComponent>? generatedQueryParams,
  ) {
    final hasPathParams = generatedPathParams?.isNotEmpty == true;
    final hasQueryParams = generatedQueryParams?.isNotEmpty == true;
    if (!hasPathParams && !hasQueryParams) return '';

    final StringBuffer buffer = StringBuffer();

    if (hasPathParams) {
      buffer.writeln('final pathUriParams = [');
      for (final param in generatedPathParams!) {
        final style = param.source.style ?? defaultPathParamStyle;
        final explode = param.source.explode ?? defaultPathParamExplode;

        final type = (param.isSchema
                ? param.schemaComponent?.dataElement.type
                : param.contentManifest?.manifest.name) ??
            dynamicType;

        final name = param.source.name;

        final isRequired = param.source.isRequired == true;

        final defaultValue = (param.schemaComponent != null && !isRequired)
            ? defaultValueGenerator
                .generateOrNull(param.schemaComponent!.dataElement)
            : null;

        final isNullable = param.isNullable &&
            type != dynamicType &&
            !type.endsWith(nullableCharacter);

        /// should we use '?' or ''
        final nullableValue =
            isNullable || (!isRequired && defaultValue == null)
                ? nullableCharacter
                : '';

        final isGenerateSchema = param.isSchema && param.isGenerated;

        final toJsonValue = isGenerateSchema ? '.toJson()' : '';

        if (nullableValue == nullableCharacter) {
          buffer.writeln('if($name != null)');
        }
        buffer.writeln(
          '$name$toJsonValue.$toUriParamMethod(\'$name\',\'$style\',$explode),',
        );
      }
      buffer.writeln('];');
    }

    if (hasQueryParams) {
      buffer.writeln('final queryUriParams = [');

      for (final param in generatedQueryParams!) {
        final style = param.source.style ?? defaultQueryParamStyle;
        final explode = param.source.explode ?? defaultQueryParamExplode;

        final name = param.source.name;

        final type = (param.isSchema
                ? param.schemaComponent?.dataElement.type
                : param.contentManifest?.manifest.name) ??
            dynamicType;

        final isRequired = param.source.isRequired == true;

        final defaultValue = (param.schemaComponent != null && !isRequired)
            ? defaultValueGenerator
                .generateOrNull(param.schemaComponent!.dataElement)
            : null;

        final isNullable = param.isNullable &&
            type != dynamicType &&
            !type.endsWith(nullableCharacter);

        /// should we use '?' or ''
        final nullableValue =
            isNullable || (!isRequired && defaultValue == null)
                ? nullableCharacter
                : '';

        final isGenerateSchema = param.isSchema && param.isGenerated;

        final toJsonValue = isGenerateSchema ? '.toJson()' : '';

        if (nullableValue == nullableCharacter) {
          buffer.writeln('if($name != null)');
        }

        buffer.writeln(
          '$name$toJsonValue.$toUriParamMethod(\'$name\',\'$style\',$explode),',
        );
      }

      buffer.writeln('];');
    }

    buffer.writeln('$pathVarName = $parameterParserVarName.parseUri(');
    buffer.writeln('pathURL : $pathVarName,');
    if (hasPathParams) {
      buffer.writeln('pathParameters : pathUriParams,');
    }
    if (hasQueryParams) {
      buffer.writeln('queryParameters : queryUriParams,');
    }
    buffer.writeln(');');
    return buffer.toString();
  }

  // final headerParams = {'accept': 'json'};
  String _generateParsedHeaderParameters(
    List<GeneratedParameterComponent>? generatedHeaderParams,
  ) {
    if (generatedHeaderParams?.isEmpty ?? true) return '';

    final StringBuffer buffer = StringBuffer();

    buffer.writeln('final $headerParamVarName = {');

    for (final param in generatedHeaderParams!) {
      final style = param.source.style ?? defaultHeaderParamStyle;
      final explode = param.source.explode ?? defaultHeaderParamExplode;

      final name = param.source.name;

      final type = (param.isSchema
              ? param.schemaComponent?.dataElement.type
              : param.contentManifest?.manifest.name) ??
          dynamicType;

      final isRequired = param.source.isRequired == true;

      final defaultValue = (param.schemaComponent != null && !isRequired)
          ? defaultValueGenerator
              .generateOrNull(param.schemaComponent!.dataElement)
          : null;

      final isNullable = param.isNullable &&
          type != dynamicType &&
          !type.endsWith(nullableCharacter);

      /// should we use '?' or ''
      final nullableValue = isNullable || (!isRequired && defaultValue == null)
          ? nullableCharacter
          : '';

      final isGenerateSchema = param.isSchema && param.isGenerated;

      final toJsonValue = isGenerateSchema ? '.toJson()' : '';

      if (nullableValue == nullableCharacter) {
        buffer.writeln('if($name != null)');
      }
      buffer.write('\'$name\': $parameterParserVarName.parseHeader(');
      buffer.write(
        '$name$toJsonValue.$toUriParamMethod(\'$name\',\'$style\',$explode,),),',
      );
    }

    buffer.writeln('};');

    return buffer.toString();
  }

  // final bodyValue = body.toBody();
  String _generateInitialBody(
    GeneratedRequestBodyComponent operationBodyComponent,
  ) {
    final type =
        operationBodyComponent.contentManifest?.manifest.name ?? dynamicType;

    final isRequired = operationBodyComponent.source.isRequired == true;

    final isNullable =
        !isRequired && type != dynamicType && !type.endsWith(nullableCharacter);

    final nullableChar = isNullable ? nullableCharacter : '';
    return 'final $bodyValueVarName = $bodyVarName${type == dynamicType ? '' : '$nullableChar.$toBodyMethod'};';
  }

  // final option =  Options(
  //   method: POSt,
  //   contentType : contentType,
  //   headers : headerParams,
  // );
  String _generateRequestOptions(
    String method,
    List<GeneratedParameterComponent>? generatedHeaderParams,
  ) {
    final StringBuffer buffer = StringBuffer();

    buffer.write('final $optionsVarName = $dioOptionsType(');

    buffer.writeln('$dioOptionMethod: \'${method.constantCase}\',');

    buffer.writeln('$contentTypeVariable: $contentTypeVariable,');

    if (generatedHeaderParams?.isNotEmpty ?? false) {
      buffer.writeln('$dioOptionHeaders: $headerParamVarName,');
    }

    buffer.writeln(');');

    return buffer.toString();
  }

  // return await dio
  //   .request(
  //     path,
  //     options: options,
  //   )
  //   .toResult(
  //     (response) => response,
  //   );
  String _generateDioRequestWithResult(
    String responseTypeName,
    List<GeneratedParameterComponent>? generatedQueryParams,
    GeneratedRequestBodyComponent? operationBodyComponent,
  ) {
    final StringBuffer buffer = StringBuffer();

    buffer.write('return await $dioInstance.request($pathVarName, ');

    buffer.writeln('$dioOptions: $optionsVarName,');

    if (operationBodyComponent != null) {
      buffer.writeln('$dioData: $bodyValueVarName,');
    }

    buffer.writeln(')');
    buffer.writeln('.toResult(');
    if (responseTypeName != dioResponseType) {
      buffer.writeln('($responseVarName) => ${responseTypeName}Ext.from(');
      buffer.writeln('$responseVarName,');
      buffer.writeln('$responseContentTypeVariable,');
      buffer.writeln('),');
    } else {
      buffer.writeln('($responseVarName) => $responseVarName,');
    }

    buffer.writeln(');');

    return buffer.toString();
  }

  String _generateDioRequestWithoutResult(
    String responseTypeName,
    List<GeneratedParameterComponent>? generatedQueryParams,
    GeneratedRequestBodyComponent? operationBodyComponent,
  ) {
    final StringBuffer buffer = StringBuffer();

    buffer.write(
        'final $responseVarName = await $dioInstance.request($pathVarName, ');

    buffer.writeln('$dioOptions: $optionsVarName,');

    if (operationBodyComponent != null) {
      buffer.writeln('$dioData: $bodyValueVarName,');
    }

    buffer.writeln(');');

    if (responseTypeName != dioResponseType) {
      buffer
        ..writeln('return ${responseTypeName}Ext.from(')
        ..writeln('$responseVarName,')
        ..writeln('$responseContentTypeVariable,')
        ..writeln(');');
    } else {
      buffer.writeln('return $responseVarName;');
    }

    return buffer.toString();
  }
}
