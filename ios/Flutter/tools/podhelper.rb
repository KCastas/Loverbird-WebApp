require 'xcodeproj'

def parse_KV_file(file, separator='=')
    return {} unless File.exist?(file)
    File.read(file).split("\n").map { |line| line.strip.split(separator, 2) }.reject { |kv| kv.length != 2 }.to_h
end

def install_all_flutter_pods(application_path = nil)
    if application_path.nil?
        application_path = Dir.pwd
    end

    ios_application_path = File.expand_path(application_path, __dir__)
    flutter_application_path = File.expand_path('..', ios_application_path)
    flutter_ios_engine_path = File.expand_path('bin/cache/artifacts/engine/ios', flutter_application_path)

    if !File.exist?(flutter_ios_engine_path)
        abort('Flutter iOS engine not found. Run "flutter precache --ios" and try again.')
    end

    load File.join(flutter_application_path, '.flutter-plugins')
    load File.join(flutter_application_path, '.flutter-plugins-dependencies')

    install_flutter_engine_pods(flutter_application_path)
end

def install_flutter_engine_pods(flutter_application_path)
    engine_dir = File.expand_path('bin/cache/artifacts/engine', flutter_application_path)
    framework_name = 'Flutter.framework'
    pod 'Flutter', :path => File.join(engine_dir, 'ios-release', framework_name)
end
