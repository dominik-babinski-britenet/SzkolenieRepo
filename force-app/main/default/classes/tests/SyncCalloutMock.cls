global class SyncCalloutMock implements HttpCalloutMock {
    public static Boolean wasExecuted = false;
    String returnedStatus;

    global SyncCalloutMock(String returnedStatus) {
        this.returnedStatus = returnedStatus;
    }

    global HttpResponse respond(HttpRequest req) {
        System.assertEquals('callout:SynchronizeProducts/services/apexrest/productsync', req.getEndpoint());

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json; charset=utf8');

        ProductRestService.DataModel dataModel = new ProductRestService.DataModel();
        dataModel.status = returnedStatus;
        res.setBody(Blob.valueOf(JSON.serialize(dataModel)).toString());
        res.setStatusCode(returnedStatus != LogUtils.CONNECTION_ERROR ? 200 : 401);
        wasExecuted = true;
        return res;
    }
}