require 'pp'

setup_file_name=ARGV[0].gsub(/\\/,"/")
setup_ids= ARGV[1].nil? ? [] : ARGV[1].split(',').collect(){|id| id.to_i}
#puts setup_file_name
#pp setup_ids

=begin
Setup.dat auswerten:
Die Werte werden als WORD (vorzeichenlos) binär in der Setup.dat gespeichert.

Zwei Bytes ergeben den Wert eines Setupparameters.

Beispiel:
Setupwert
Dezimal: 380
Binär:  | 00000001 | 01111100 |

Byte n:   1111100
Byte n+1: 1

nach auffüllen:
Byte n:   01111100
Byte n+1: 00000001

=> | Byte n+1 | Byte n | ergeben den gesucht Wert

Da Byte n zuerst eingelesen wird, muss Byte n+1  um 1 Byte ( 8 Stellen ) nach links geshiftet werden.
Den ganzen Wert ergibt dann die Binäroperation OR oder XOR.

=end


def param_name(dir, id)
  params=%w{deutsch.lng english.lng}
  param_regexp = /PARAM#{id}=/

  help_params=params.collect() do |p|
    (1..3).to_a().collect() do |n|
      p.split('.').join("#{n}.")
    end
  end.flatten()
  help_param_regexp = /HILFEPARAM#{id}=/

  names=[]
  params.each() do |param_file|
    File.open(File.join(dir, param_file), "r") do |f|
      f.readlines().each() {|line| names << "#{param_file}: #{line.split(param_regexp).last}" if line =~ param_regexp }
    end
  end
  help_params.each() do |param_file|
    File.open(File.join(dir, param_file), "r") do |f|
      f.readlines().each() {|line| names << "#{param_file}: #{line.split(help_param_regexp).last.gsub(/§§/, " ") }" if line =~ help_param_regexp }
    end
  end

  names
end

File.open(setup_file_name, "rb") do |file|
  puts "\t\tDez\tHex\tOkt\tBin" if setup_ids.empty?
  puts "\t\t---\t---\t---\t---" if setup_ids.empty?
  counter=0
  sor=nil
  sxor=nil
  while(b = file.getc)
    c = b.chr
    if sor.nil? then
      sor= b
      sxor= b
    else
      sor= (b << 8) | sor
      sxor= (b << 8) ^ sxor
    end

    puts "i:#{counter},\t, #{Regexp.escape(c)},\t#{b},\t0x#{b.to_s(16).upcase},\to#{b.to_s(8).upcase},\t#{b.to_s(2)}" if setup_ids.empty?
    if counter % 2 == 1 then

      if setup_ids.empty?
        puts "sp:#{counter/2}\t, #{Regexp.escape(c)},\t#{sor},\t0x#{sor.to_s(16).upcase},\to#{sor.to_s(8).upcase},\t#{sor.to_s(2)}"
        puts "sp:#{counter/2}\t, #{Regexp.escape(c)},\t#{sxor},\t0x#{sxor.to_s(16).upcase},\to#{sxor.to_s(8).upcase},\t#{sxor.to_s(2)}"
        puts "-"*45        
      else
        if setup_ids.include?(counter/2)
          puts "#{counter / 2}\t: #{sor}"
          puts param_name(File.dirname(setup_file_name), counter/2)
          puts "-"*45
        end
      end


      sor=nil
      sxor=nil
    end

    counter=counter+1

    #break if counter > 16

  end
end