SimpleApiClient
===============

Clean and snappy.

A simple RESTful ApiClient that utilizes the NSURLConnection category method sendAsynchronousRequest:queue:completionHandler:

The request method takes NSObjects (NSStrings, NSArrays, NSDictionarys) and packs the request with the correct encoding.

This class also does api error checking.

iOS 5.0 and newer only.

You can add your own subclient categories to this class to create a robust custom APIClient.