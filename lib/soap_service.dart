import 'package:http/http.dart' as http;

class SoapService {
  final String endpointUrl;

  SoapService(this.endpointUrl);

  Future<String> callWebService(String methodName, String soapAction,
      Map<String, dynamic> parameters) async {
    final soapHeaders = {
      'Content-Type': 'text/xml; charset=utf-8',
      'SOAPAction':
          soapAction, // Utiliza la acción SOAP proporcionada como parámetro
    };

    final envelope = '''
      <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:web="$endpointUrl">
        <soapenv:Header/>
        <soapenv:Body>
          <$methodName>
            ${_buildRequestParameters(parameters)}
          </$methodName>
        </soapenv:Body>
      </soapenv:Envelope>
    ''';

    final response = await http.post(
      Uri.parse(endpointUrl),
      headers: soapHeaders,
      body: envelope,
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Error en la solicitud SOAP: ${response.statusCode}');
    }
  }

  String _buildRequestParameters(Map<String, dynamic> parameters) {
    final buffer = StringBuffer();

    // Iterate over the parameters and build XML elements
    parameters.forEach((key, value) {
      buffer.writeln('<$key>${_convertToXmlValue(value)}</$key>');
    });

    return buffer.toString();
  }

  String _convertToXmlValue(dynamic value) {
    if (value is String) {
      // If the value is a string, escape special characters and wrap in CDATA
      return '<![CDATA[$value]]>';
    } else if (value is int || value is double) {
      // If the value is a number, convert to string
      return value.toString();
    } else if (value is Map<String, dynamic>) {
      // If the value is a nested map, recursively build XML
      return _buildRequestParameters(value);
    } else {
      // Handle other data types as needed
      return value.toString();
    }
  }
}
