$c_sharp_source = @'
using System;
using System.IO;
namespace global {
   public class lineUtils {
      public const int CR = 13;
      public const int LF = 10;
      public static void dos2unix(string filePath) {
         byte[] sourceBytes = File.ReadAllBytes(filePath);
         long newSize = sourceBytes.Length;
         using (FileStream destFs = new FileStream(filePath,
                                                   FileMode.Open,
                                                   FileAccess.ReadWrite)) {
            destFs.Position = 0;
            for (long i = 0; i < sourceBytes.Length; ++i) {
               if (sourceBytes[i] != CR) {
                  destFs.WriteByte((byte)sourceBytes[i]);
               } else {
                  --newSize;
               }
            }
            destFs.SetLength(newSize);
         }
      }
      public static void unix2dos(string filePath) {
         byte[] sourceBytes = File.ReadAllBytes(filePath);
         using (FileStream destFs = new FileStream(filePath,
                                                   FileMode.Open,
                                                   FileAccess.ReadWrite)) {
            destFs.Position = 0;
            for (long i = 0; i < sourceBytes.Length; ++i) {
               if (sourceBytes[i] == LF) {
                  destFs.WriteByte(CR);
                  destFs.WriteByte(LF);
               } else {
                  destFs.WriteByte((byte)sourceBytes[i]);
               }
            }
         }
      }
   }
}
'@

Add-Type -TypeDefinition $c_sharp_source -Language CSharp

# Convert UNIX/Linux LF line endings to DOS/Windows CRLF
$files = Get-ChildItem -Recurse -File -Exclude '*.jar', '*.class', '*.dll'
ForEach ($p In $files.FullName) {
   Write-Host $p
   [global.lineUtils]::unix2dos($p)
}
# Convert DOS/Windows CRLF line endings to UNIX/Linux LF
$files = Get-ChildItem -Recurse -File -Exclude '*.jar', '*.class', '*.dll'
ForEach ($p In $files.FullName) {
   Write-Host $p
   [global.lineUtils]::dos2unix($p)
}
