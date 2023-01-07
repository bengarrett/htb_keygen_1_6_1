Mapping2BMP	PROTO :DWORD, :DWORD		;Adress of the file memory mapping, address of structure
Res2BMP		PROTO :DWORD, :DWORD, :DWORD	;Main app instance, resource ID, address of structure
Kill_JPEG	PROTO :DWORD			;Address of structure

JPEG_STRUCTURE	struct
	dwWidth		DWORD ?		;Width of the picture
	dwHeight	DWORD ?		;Height of the picture
	BMPWidth	DWORD ?		;Width of the bitmap
	BMPHeight	DWORD ?		;Height of the bitmap
;	hBitMap		DWORD ?		;Bitmap handle
	lpBitMap	DWORD ?		;Bitmap address
JPEG_STRUCTURE	ends