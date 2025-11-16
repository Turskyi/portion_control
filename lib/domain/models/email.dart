class Email {
  const Email({
    this.subject = '',
    this.recipients = const <String>[],
    this.cc = const <String>[],
    this.bcc = const <String>[],
    this.body = '',
    this.attachmentPaths,
    this.isHtml = false,
  });

  final String subject;
  final List<String> recipients;
  final List<String> cc;
  final List<String> bcc;
  final String body;
  final List<String>? attachmentPaths;
  final bool isHtml;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'subject': subject,
      'body': body,
      'recipients': recipients,
      'cc': cc,
      'bcc': bcc,
      'attachment_paths': attachmentPaths,
      'is_html': isHtml,
    };
  }
}
