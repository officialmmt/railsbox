describe EnvironmentsConfiguration do
  describe '#save' do
    let(:params) do
      params_fixture.merge({
        staging: {
          target: 'ec2'
        }
      })
    end
    subject { described_class.new(params) }

    before { @dir = Dir.mktmpdir }
    before { CopyConfiguration.new(params).save(@dir) }
    before { subject.save(@dir) }

    it 'creates development directory' do
      expect(Dir).to exist(File.join(@dir, 'development'))
    end

    it 'creates staging directory' do
      expect(Dir).to exist(File.join(@dir, 'staging'))
    end

    describe 'development - VirtualBox' do
      let(:vagrantfile_path) { File.join(@dir, 'development', 'Vagrantfile') }

      it 'copies Vagrantfile' do
        expect(File).to exist(vagrantfile_path)
      end

      context 'Vagrantfile' do
        let(:output) { IO.read(vagrantfile_path) }

        it 'sets name' do
          expect(output).to include %Q(.vm.define 'testapp')
          expect(output).to include %Q(hostname = 'localhost')
        end

        it 'sets operating system' do
          expect(output).to include %Q(.vm.box = 'ubuntu/trusty64')
        end

        it 'sets memory' do
          expect(output).to include %Q(sysctl -n hw.memsize)
        end

        it 'sets cores' do
          expect(output).to include %Q(sysctl -n hw.ncpu)
        end

        it 'sets forwarded port' do
          expect(output).to include %Q(vm.network 'forwarded_port', :guest => 80, :host => 8080)
        end

        it 'sets box ip' do
          expect(output).to include %Q(.vm.network 'private_network', ip: '192.168.20.50')
        end
      end
    end

    after { FileUtils.remove_entry_secure @dir }
  end
end
