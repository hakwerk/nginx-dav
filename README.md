# nginx-dav

DAV enabled version of nginx. The official nginx image, extended with the following modules:
- http_dav_module
- [arut/nginx-dav-ext-module](https://github.com/arut/nginx-dav-ext-module.git)
- [openresty/headers-more-nginx-module](https://github.com/openresty/headers-more-nginx-module.git)
- [aperezdc/ngx-fancyindex](https://github.com/aperezdc/ngx-fancyindex.git)


WebDAV (Web Distributed Authoring and Versioning) is a set of extensions to the Hypertext Transfer Protocol (HTTP), which allows user agents to collaboratively author contents directly in an HTTP web server by providing facilities for concurrency control and namespace operations, thus allowing Web to be viewed as a writeable, collaborative medium and not just a read-only medium.

WebDAV is defined in RFC4918.