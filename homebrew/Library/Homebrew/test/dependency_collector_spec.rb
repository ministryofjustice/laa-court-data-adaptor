# typed: false
# frozen_string_literal: true

require "dependency_collector"

describe DependencyCollector do
  alias_matcher :be_a_build_requirement, :be_build

  def find_dependency(name)
    subject.deps.find { |dep| dep.name == name }
  end

  def find_requirement(klass)
    subject.requirements.find { |req| req.is_a? klass }
  end

  describe "#add" do
    specify "dependency creation" do
      subject.add "foo" => :build
      subject.add "bar" => ["--universal", :optional]
      expect(find_dependency("foo")).to be_an_instance_of(Dependency)
      expect(find_dependency("bar").tags.count).to eq(2)
    end

    it "returns the created dependency" do
      expect(subject.add("foo")).to eq(Dependency.new("foo"))
    end

    specify "requirement creation" do
      subject.add :x11
      expect(find_requirement(X11Requirement)).to be_an_instance_of(X11Requirement)
    end

    it "deduplicates requirements" do
      2.times { subject.add :x11 }
      expect(subject.requirements.count).to eq(1)
    end

    specify "requirement tags" do
      subject.add :x11
      subject.add xcode: :build
      expect(find_requirement(X11Requirement).tags).to be_empty
      expect(find_requirement(XcodeRequirement)).to be_a_build_requirement
    end

    specify "x11 without tag" do
      subject.add :x11
      expect(find_requirement(X11Requirement).tags).to be_empty
    end

    specify "x11 with tag" do
      subject.add x11: :optional
      expect(find_requirement(X11Requirement)).to be_optional
    end

    it "doesn't mutate the dependency spec" do
      spec = { "foo" => :optional }
      copy = spec.dup
      subject.add(spec)
      expect(spec).to eq(copy)
    end

    it "creates a resource dependency from a CVS URL" do
      resource = Resource.new
      resource.url(":pserver:anonymous:@brew.sh:/cvsroot/foo/bar", using: :cvs)
      expect(subject.add(resource)).to eq(Dependency.new("cvs", [:build, :test]))
    end

    it "creates a resource dependency from a '.7z' URL" do
      resource = Resource.new
      resource.url("https://brew.sh/foo.7z")
      expect(subject.add(resource)).to eq(Dependency.new("p7zip", [:build, :test]))
    end

    it "creates a resource dependency from a '.gz' URL" do
      resource = Resource.new
      resource.url("https://brew.sh/foo.tar.gz")
      expect(subject.add(resource)).to be nil
    end

    it "creates a resource dependency from a '.lz' URL" do
      resource = Resource.new
      resource.url("https://brew.sh/foo.lz")
      expect(subject.add(resource)).to eq(Dependency.new("lzip", [:build, :test]))
    end

    it "creates a resource dependency from a '.lha' URL" do
      resource = Resource.new
      resource.url("https://brew.sh/foo.lha")
      expect(subject.add(resource)).to eq(Dependency.new("lha", [:build, :test]))
    end

    it "creates a resource dependency from a '.lzh' URL" do
      resource = Resource.new
      resource.url("https://brew.sh/foo.lzh")
      expect(subject.add(resource)).to eq(Dependency.new("lha", [:build, :test]))
    end

    it "creates a resource dependency from a '.rar' URL" do
      resource = Resource.new
      resource.url("https://brew.sh/foo.rar")
      expect(subject.add(resource)).to eq(Dependency.new("unrar", [:build, :test]))
    end

    it "raises a TypeError for unknown classes" do
      expect { subject.add(Class.new) }.to raise_error(TypeError)
    end

    it "raises a TypeError for unknown Types" do
      expect { subject.add(Object.new) }.to raise_error(TypeError)
    end

    it "raises a TypeError for a Resource with an unknown download strategy" do
      resource = Resource.new
      resource.download_strategy = Class.new
      expect { subject.add(resource) }.to raise_error(TypeError)
    end
  end
end
