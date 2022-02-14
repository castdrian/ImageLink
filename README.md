[![GitHub version](https://badge.fury.io/gh/adrifcastr%2FImageLink.svg)](https://github.com/adrifcastr/ImageLink)
[![Support Server](https://img.shields.io/discord/844574704698130492.svg?color=7289da&label=ImageLink&logo=discord&style=flat-round)](https://discord.gg/d23n5vAbD5)

# ImageLink
### ImageLink is the (non-affiliated) mobile ShareX-like uploader client!

With ImageLink you can upload images, videos and files to your own server!
You can import existing .sxcu configuration that you use on your desktop devices and are immediately ready to go!

- Automatically pastes the response URL into your clipboard
- Share files to ImageLink for an immediate upload
- Intercept and upload screenshots if wanted

You can [download ImageLink from Google Play](https://play.google.com/store/apps/details?id=com.castdrian.imagelink)!\
You can [join the ImageLink Discord Guild](https://discord.gg/d23n5vAbD5) if you have any questions or feedback!


### Screenshots

<a href="https://cdn.adriancastro.dev/vHGLDDX.png"><img src="https://cdn.adriancastro.dev/vHGLDDX.png"/></a>
<a href="https://cdn.adriancastro.dev/KEoIKAW.png"><img src="https://cdn.adriancastro.dev/KEoIKAW.png"/></a>


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
