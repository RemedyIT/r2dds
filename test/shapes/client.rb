#--------------------------------------------------------------------
#
# Author: Johnny Willemsen
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the R2DDS LICENSE which is
# included with this program.
#
# Copyright (c) Remedy IT Expertise BV
#--------------------------------------------------------------------

require 'optparse'
require 'lib/assert.rb'
include TestUtil::Assertions

OPTIONS = {
  :dcps_debuglevel => 0,
}

ARGV.options do |opts|
    script_name = File.basename($0)
    opts.banner = "Usage: ruby #{script_name} [options]"

    opts.separator ""

    opts.on("--d LVL",
            "Set DCPSDebugLevel value.",
            "Default: 0") { |v| OPTIONS[:dcps_debuglevel]=v }

    opts.separator ""

    opts.on("-h", "--help",
            "Show this help message.") { puts opts; exit }

    opts.parse!
end

require 'dds'

class ShapeListener < DDS::DataReaderListener
  def initialize()
  end

  def on_data_available(reader)
    puts "Ruby on_data_available!"
    shape = ShapeType.new("ORANGE", 10, 10, 10)
    reader.read (shape);
    puts "Read sample #{shape.color()} #{shape.x()} #{shape.y()} #{shape.shapesize()}";
  end
end

begin

dfp = DDS.DomainParticipantFactory_init()
dp = dfp.create_participant()
topic = dp.create_topic()
pub = dp.create_publisher()
sub = dp.create_subscriber()
dw = pub.create_datawriter(topic)

listener = ShapeListener.new()

dr = sub.create_datareader(topic, listener)

$i = 0
$num = 10
shape = ShapeType.new("ORANGE", 10, 10, 10)

while $i < $num  do
  dw.write(shape)
  shape.shapesize = $i * 10
  shape.x = $i * 10 + 10
  shape.y = $i * 10 + 10
  shape.color = "RED"
  $i=$i+1
  sleep(1)
end

pub = dp.delete_contained_entities()

ensure

end
