STDERR.puts
STDERR.puts "Building Firefox Extension..."

Dir.chdir File.dirname(File.expand_path(__FILE__))
Dir.chdir 'firefox_extension'
Dir.chdir 'chrome'
`zip -r blood_on_the_tracks.jar content/*` # TODO also zip skin dir when we have one
Dir.chdir '..'
`zip blood_on_the_tracks.xpi install.rdf chrome.manifest chrome/blood_on_the_tracks.jar`
`rm chrome/blood_on_the_tracks.jar`

STDERR.puts
STDERR.puts <<MSG
Blood on the Tracks successfully installed! To install the Firefox
extension, visit http://localhost:3000/blood_on_the_tracks/install

For more info, see http://github.com/bradleybuda/bloodonthetracks

Thanks!
MSG
STDERR.puts

