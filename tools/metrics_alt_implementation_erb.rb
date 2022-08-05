require 'yaml'
require "erb"
require "redcarpet"
require "fileutils"

class ProcessMetrics
  def initialize(yamlMetricsSource, htmlInputTemplate, htmlOutput)
    @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, lax_spacing: true, autolink: true, no_intra_emphasis: true)

    if yamlMetricsSource == nil || yamlMetricsSource == ""
      @YAMLMetricsSource = "data/primary-dataset.yml"
    else
      @YAMLMetricsSource = yamlMetricsSource
    end
    if htmlInputTemplate == nil || htmlInputTemplate == ""
      @HTMLInputTemplate = "data/metrics-catalog.template"
    else
      @HTMLInputTemplate=htmlInputTemplate
    end
    if htmlOutput == nil || htmlOutput == ""
      @HTMLOutput = "metrics-catalog.html"
    else
      @HTMLOutput=htmlOutput  
    end

  end  

  def IsFilePresent?(fileName)
    fileName.strip! 
    puts "#{File.absolute_path(fileName,".")}\t#{File.exists?(File.absolute_path(fileName,"."))}\n"
    return File.exists?(fileName)
  end
  def GetFileHandle(sourceFile, fileType) # returns fileHandle
      if IsFilePresent?(sourceFile)
        begin
          case fileType
          when "yaml"
            fileHandle=YAML.load_file(File.absolute_path(sourceFile,"."))
          when "template"
            fileHandle=File.read(File.absolute_path(sourceFile,"."))
          when "output"
            begin
              # move old file 
              FileUtils.move sourceFile, sourceFile+".backup."+Time.now().to_i.to_s
            rescue
              p "Cannot move output file #{sourceFile} in path #{Dir.pwd}. Exit"
              exit
              # return fileHandle      
            end
            fileHandle=File.open(File.absolute_path(sourceFile,"."),mode="w")              
          else
            p "File type #{fileType} not supported"
            exit
          end
        rescue StandardError => e
          p "Cannot process file #{File.absolute_path(sourceFile,".")}. Error = #{e.message}. Exit"
          exit
        end
      elsif fileType=="output"
        begin
          fileHandle=File.open(File.absolute_path(sourceFile,"."),mode="w")
          return fileHandle              
        rescue StandardError => e
          p "Cannot process file #{File.absolute_path(sourceFile,".")}. Error = #{e.message}. Exit"
          exit
        end
      else  
        p "#{sourceFile} file not present in path #{Dir.pwd}. Exit"
        exit
        # return fileHandle
      end
  end
  def GetFileHandles()
    @YAMLMetricsHandle=GetFileHandle(@YAMLMetricsSource, "yaml")
    @HTMLInputFileHandle=GetFileHandle(@HTMLInputTemplate, "template")
    @HTMLOutputFileHandle=GetFileHandle(@HTMLOutput, "output") 
  end
  def CloseFiles()
  end

  def ConstructCCMReferenceHash()
    
    ccmreferencehash = Hash.new {|hshouter,keyouter| hshouter[keyouter]=Hash.new {|hshinner,keyinner| hsinner[keyinner]=''}}
    @ccmreferences.each do |ccmitem|
      controlid=ccmitem['id']
      controlspec=ccmitem['specification']
      controltitle=ccmitem['title']
      ccmreferencehash[controlid]['specification']=controlspec
      ccmreferencehash[controlid]['title']=controltitle
    end
    return ccmreferencehash
  end
  
  def ProcessYAML()
    @processDTM = Time.now().utc
    @name= @YAMLMetricsHandle['name']
    @version= @YAMLMetricsHandle['version']
    @copyright=@YAMLMetricsHandle['copyright']
    @ccmversion=@YAMLMetricsHandle['ccm_version']
    @url = @YAMLMetricsHandle['url']

    @metrics = @YAMLMetricsHandle['metrics']
    @ccmreferences=@YAMLMetricsHandle['ccm_references']
  end

  def ConvertMarkdownToHTML(mdtext)
    begin
      htmltext = @markdown.render(mdtext)
    rescue => exception
      puts "Cannot process markdsown #{exception}"
      return ''
    end  
    return htmltext
  end

  def ProcessRulesMarkdown()
    @metricsrulesinhtml = Hash.new {|h,k| h[k]=''}
    @metrics.each do |metric|
      metricid = metric['id']
      begin
        mdtext = metric['rules']
        htmltext = ConvertMarkdownToHTML(mdtext)
        @metricsrulesinhtml[metricid]=htmltext
      rescue 
        @metricsrulesinhtml[metricid]=''
      end
    end
  end 

  def ConstructRelatedIds()
    @relatedids = Hash.new {|h,k| h[k]=''}
    @metrics.each do |metric|
      metricid = metric['id']
      @relatedids[metricid]=''
      begin
        relatedidslice = metric['relatedids']
        csvrelatedids = ''
        relatedidslice.each do |k,relatedid|
          csvrelatedids << relatedid + ','
        end
        @relatedids[metricid]=csvrelatedids
      rescue 
      end
    end
  end

  def ProcessHTMLOutline()    
    self.GetFileHandles()
    self.ProcessYAML()
    @ccmreferencehash = self.ConstructCCMReferenceHash()
    self.ConstructRelatedIds()
    self.ProcessRulesMarkdown()
    htmlOutput = ERB.new(@HTMLInputFileHandle).result(binding)
    @HTMLOutputFileHandle.write(htmlOutput)
    return 
  end

end

processor = ProcessMetrics.new("","","")
processor.ProcessHTMLOutline()