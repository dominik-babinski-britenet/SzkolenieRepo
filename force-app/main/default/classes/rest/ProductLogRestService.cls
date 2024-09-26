@RestResource(urlMapping='/log/*')
public with sharing class ProductLogRestService {
    @HttpPost
    global static void handlePostRequest() {
        RestResponse response = RestContext.response;

        RestRequest req = RestContext.request; // Get the current request

        // Convert headers map into a string
        String headersAsString = '';
        for (String headerName : req.headers.keySet()) {
            headersAsString += headerName + ' : ' + req.headers.get(headerName) + '\n';
        }

        System.debug('Headers: \n' + headersAsString); // Debug the headers as string
        String body = request.requestBody;
    }
}