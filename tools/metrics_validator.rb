require 'yaml'
require 'nokogiri'
require 'redcarpet'

class Duration 
  class ParseError < StandardError
  end

  attr_accessor :years
  attr_accessor :months
  attr_accessor :days
  attr_accessor :hours
  attr_accessor :minutes
  attr_accessor :seconds

  def initialize(years: 0, months: 0, days: 0, hours: 0, minutes: 0, seconds: 0.0)
    @years = years
    @months = months
    @days = days
    @hours = hours
    @minutes = minutes
    @seconds = seconds
  end

  def self.from_iso8601(iso)
    match = iso.match(/P(?:([0-9]*Y))?(?:([0-9]*M))?(?:([0-9]*D))?(?:T(?:([0-9]*)H)?(?:([0-9]*)M)?(?:([0-9.]*)S)?)?/)
    unless match
      raise ParseError, "#{iso} is not an ISO8601 duration."
    end
    years = match[1].to_i
    months = match[2].to_i
    days = match[3].to_i
    hours   = match[4].to_i
    minutes = match[5].to_i
    seconds = match[6].to_f
    Duration.new(years: years, months: months, days: days, hours: hours, minutes: minutes, seconds: seconds)
  end

  def humanize
    human = []
    humanize_push(human, @years, "year")
    humanize_push(human, @months, "month")
    humanize_push(human, @days, "day")
    humanize_push(human, @hours, "hour")
    humanize_push(human, @minutes, "minute")
    humanize_push(human, @seconds, "second")
    if human.size == 0 
      return "None"
    end
    return human.join(", ")
  end
  private
  def humanize_push(human, attr, singular)
    if attr!=0
      if attr==1
        human << "1 #{singular}"
      else
        human << "#{attr} #{singular}s"
      end
    end
  end
end

class Markdown 
  def initialize
    @markdown_engine = Redcarpet::Markdown.new(Redcarpet::Render::HTML, lax_spacing: true, autolink: true, no_intra_emphasis: true)
  end

  def render(doc, data)
    if data
      doc << @markdown_engine.render(data)
    end
  end
end

if ARGV.length!=2
  puts "Usage: #{__FILE__} <source_yaml_file> <html_rending>"
  exit false
end
yaml_source = ARGV[0]
html_render = ARGV[1]

begin
  data = YAML.load_file(yaml_source)
rescue StandardError => e
  puts "Invalid YAML file, #{e.message}"
  exit false
end

def table_line(doc, key, value, color)
  doc.div key, class: "key #{color}"
  if block_given?
    doc.div class: 'value' do
      yield
    end
  else
    doc.div value, class: 'value'
  end
end

markdown = Markdown.new

builder = Nokogiri::HTML::Builder.new do |doc|
  doc.html do
    doc.head do
      doc.link rel: "preconnect", href: "https://fonts.googleapis.com"
      doc.link rel: "preconnect", href: "https://fonts.gstatic.com", crossorigin: true
      doc.link href: "https://fonts.googleapis.com/css2?family=Montserrat:wght@400;700&display=swap", rel: "stylesheet"
      doc.style do
        doc.text '
        body {
          font-family: "Montserrat", sans-serif;
          width: 1250px;
          margin-left: auto;
          margin-right: auto;
        }
        .metric {
          display: grid;
          grid-template-columns: 25% auto;
          gap: 5px;
          background: #eee;
          padding: 10px;
          border-radius: 5px;
        }
        .metric .key {
          font-weight: bold;
          padding: 12px;
          color: white;
        }
        .metric .value {
          padding: 12px;
          background: white;
        }

        .green {
          background: #3ba573;
          border-left: solid 14px #29895c;
        }
        .orange {
          background: #ff9b1a;
          border-left: solid 14px #fa8526;
        }
        .blue {
          background: #0372c7;
          border-left: solid 14px #00549e;
        }
        code {
          color: #700;
          font-size: 125%;
        }
        '
      end
    end
    doc.body do
      doc.h1 "Continuous Audit Metrics Catalog, version #{data['version']}"
      doc.p "Generated on #{Time.now.utc}"
      doc.div do
        markdown.render(doc, '
This document has been automatically generated from the YAML source file at https://github.com/cloudsecurityalliance/continuous-audit-metrics/tree/main/data/primary-dataset.yml

To make changes to the catalog, please [make changes](https://github.com/cloudsecurityalliance/continuous-audit-metrics/edit/main/data/primary-dataset.yml) to the YAML file or [create an issue](https://github.com/cloudsecurityalliance/continuous-audit-metrics/issues) on github describing your requested changes.

**The content of this repository, including this file, is (c) Cloud Security Alliance, 2022**. See the LICENSE file for details.
                        ')
      end
      data['metrics'].each do |metric|
        
        unless metric['relatedControlIds'].nil? || metric['relatedControlIds'].kind_of?(Array)
          puts "Error in YAML file for metric #{metric['id']}: relatedControlIds must be a list."
          exit false
        end


        doc.h2 "Metric #{metric['id']}"
        doc.div class: 'metric' do
          table_line doc, "Primary CCMv4 Control ID", metric['primaryControlId'], 'green'
          table_line doc, "Related CCMv4 Control IDs", (metric['relatedControlIds'].join(', ') if metric['relatedControlIds']), 'green'
          table_line doc, "Metric ID", nil, 'orange' do
            doc.strong metric['id']
          end
          table_line doc, "Metric Description", metric['metricDescription'], 'orange'
          table_line doc, "Expression", nil, 'orange' do
            expression = metric['expression']
            doc.div do
              doc.text "Formula: "
              doc.code expression['formula']
            end
            doc.p do
              doc.text "Where: "
              doc.ul do
                expression['parameters'].each do |params|
                  
                  duration = Duration.new
                  begin
                    duration = Duration.from_iso8601(params['samplingPeriod']) if params['samplingPeriod']
                  rescue StandardError => e
                    puts "Error in YAML file for metric #{metric['id']}, parameter #{params['name']}: samplingPeriod is not in ISO8601 format"
                    exit false
                  end

                  doc.li do
                    doc.code params['name']
                    doc.text ': ' + params['description']
                    doc.ul do
                      doc.li "ID: #{params['id']}" if params['id']
                      doc.li "Sampling period: #{duration.humanize}"
                      doc.li "Unit: #{params['unit']}" if params['unit']
                      doc.li "Type: #{params['type']}" if params['type']
                    end
                  end
                end
              end
            end
          end
          table_line doc, "Rules", nil, 'orange' do
             markdown.render(doc, metric['rules'])
          end
          duration = Duration.new
          begin
            duration = Duration.from_iso8601(metric['samplingPeriod']) if metric['samplingPeriod']
          rescue StandardError => e
            puts "Error in YAML file for metric #{metric['id']}: samplingPeriod is not in ISO8601 format"
            exit false
          end
          table_line doc, "Sampling period", duration.humanize, 'orange'
          table_line doc, "SLO Recommendation", nil, 'blue' do
            recommendations = metric['sloRecommendations']
            if recommendations['sloRangeMin']
              doc.div "Minimum: #{recommendations['sloRangeMin']}"
            end
            if recommendations['sloPeriod']
              begin
                duration = Duration.from_iso8601(recommendations['sloPeriod'])
                doc.div "SLO Period: #{duration.humanize}"
              rescue StandardError => e
                puts "Error in YAML file for metric #{metric['id']}: sloPeriod is not in ISO8601 format"
                exit false
              end
            end
          end
        end
        doc.h3 "Implementation guidelines"
        doc.div do
          markdown.render(doc,metric['implementationGuidelines'])
        end
      end
    end
  end
end 

File.open(html_render, "w") do |file| 
  file.write(builder.to_html) 
end
