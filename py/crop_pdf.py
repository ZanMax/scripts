from pyPdf import PdfFileWriter, PdfFileReader

def crop_pdf(pdf_file):
    original = pdf_file
    target = original[:-4] + '.cropped.pdf'
    left = 0
    top = 50
    right = 0
    bottom = 0

    pdf = PdfFileReader(file(original, 'rb'))
    out = PdfFileWriter()
    for page in pdf.pages:
        page.mediaBox.upperRight = (page.mediaBox.getUpperRight_x() - right, page.mediaBox.getUpperRight_y() - top)
        page.mediaBox.lowerLeft = (page.mediaBox.getLowerLeft_x() + left, page.mediaBox.getLowerLeft_y() + bottom)
        out.addPage(page)
    ous = file(target, 'wb')
    out.write(ous)
    ous.close()
    return target

def watermark_pdf(pdf_file, watermark):
    output = PdfFileWriter()
    input1 = PdfFileReader(file(pdf_file, "rb"))
    watermark = PdfFileReader(file(watermark, "rb"))

    page1 = input1.getPage(0)
    page1.mergePage(watermark.getPage(0))

    outputStream = file("document-output.pdf", "wb")
    output.write(input1)
    outputStream.close()

# Example
crop_pdf('1.pdf')
watermark_pdf('1.cropped.pdf', '1_watermark.pdf')
