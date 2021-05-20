# ImageLink
### ImageLink is the (non-affiliated) mobile ShareX client!

With ImageLink you can upload images, videos and files to your own server!
You can import existing .sxcu configuration that you use on your desktop devices and are immediately ready to go!

- Automatically pastes the response URL into your clipboard
- Share files to ImageLink for an immediate upload
- Intercept and upload screenshots if wanted

You can [join the ImageLink Discord Guild](https://discord.gg/MSDcP79cch) if you have any questions of feedback!


### Screenshots

<a href="https://depressed-lemonade.me/kQNvKNt.png"><img src="https://depressed-lemonade.me/kQNvKNt.png"/></a>
<a href="https://depressed-lemonade.me/qSu0zbX.png"><img src="https://depressed-lemonade.me/qSu0zbX.png"/></a>


### Supported SXCU's

ImageLink supports the following types of SXCU configurations:

Multipart/form-data with JSON body arguments:
```json
{
  "DestinationType": "ImageUploader",
  "RequestMethod": "POST",
  "RequestURL": "https://example.com/upload",
  "Body": "MultipartFormData",
  "Arguments": {
    "endpoint": "upload",
    "token": "secrettoken"
  },
  "FileFormName": "image",
  "URL": "$json:url$",
  "DeletionURL": "$json:deletion_url$"
}
```

Multipart/form-data with request headers:
```json
{
  "DestinationType": "ImageUploader, FileUploader",
  "RequestType": "POST",
  "RequestURL": "https://example.com/upload",
  "Body": "Form data (multipart/form-data)",
  "FileFormName": "files[]",
  "Headers": {
    "token": "secrettoken",
    "accept": "application/json"
},
"ResponseType": "Text",
"URL": "$json:url$",
"ThumbnailURL": "$json:thumb$"
}
```

### Credits

- Adrian Castro
- Sören Stabenow
