class File1 {
  int id;
  int vault;
  String file_name;
  String? file_content;

  File1(
    this.id,
    this.vault,
    this.file_name,
    this.file_content,
  );

  factory File1.fromJson(Map<String, dynamic> json) =>
      File1(json["id"], json["vault"], json["file_name"], json["file_content"]);

  Map<String, dynamic> toJson() => {
        "id": id.toString(),
        "vault": vault.toString(),
        "file_name": file_name,
        "file_content": file_content,
      };
}
