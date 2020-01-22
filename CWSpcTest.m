classdef CWSpcTest < matlab.unittest.TestCase
    properties
        cws
        cws2D
    end
    methods 
        function obj = CWSpcTest()
            obj.cws = CWSpc('data/real1D.spc');
            obj.cws2D = CWSpc('data/real2D.spc');
            % nitroxide Sys
            Sys.A=mt2mhz([0.62 0.59 3.7]);
            Sys.g=[2.0078 2.0058 2.0022];
            Sys.S=1/2;
            Sys.Nucs='14N';
            Exp.mwFreq = 9.853;
            Exp.Range = [338.88, 358.88];
            Exp.nPoints = 1024;
            obj.cws.Sys = Sys;
            obj.cws.Exp = Exp;
        end
    end
    methods (Test)
        function test_find_mwfreq(tc)
            spc = [237.365234375000,227.365234375000,376.365234375000,443.365234375000,243.365234375000,526.365234375000,46.3652343750000,-115.634765625000,184.365234375000,226.365234375000,11.3652343750000,236.365234375000,324.365234375000,-197.634765625000,93.3652343750000,169.365234375000,-211.634765625000,182.365234375000,504.365234375000,418.365234375000,784.365234375000,21855.3652343750,-3921.63476562500,-240.634765625000,610.365234375000,10266.3652343750,-9295.63476562500,-165.634765625000,809.365234375000,6062.36523437500,-13389.6347656250,-1282.63476562500,-376.634765625000,-12.6347656250000,-30.6347656250000,274.365234375000,322.365234375000,-120.634765625000,69.3652343750000,71.3652343750000,509.365234375000,300.365234375000,21.3652343750000,-25.6347656250000,29.3652343750000,113.365234375000,198.365234375000,-85.6347656250000,186.365234375000,209.365234375000,-286.634765625000,120.365234375000];
            Sys.A=mt2mhz([0.62 0.59 3.7]);
            Sys.g=[2.0078 2.0058 2.0022];
            Sys.S=1/2;
            Sys.Nucs='14N';
            Sys.logtcorr=-9;
            Exp.mwFreq = 9.853;
            Exp.Range = [338.88, 358.88];
            Exp.nPoints = length(spc);
            x=CWSpc.find_mwFreq(spc, Sys, Exp);
            tc.assertEqual(round(x, 8), round(9.63775642108837, 8));
        end
        function testcwspc(tc)
            tc.cws = CWSpc('demo1D');
            tc.assertTrue(tc.cws.is1d);
            tc.assertEqual(tc.cws.NY, 1);
            tc.assertEqual(size(tc.cws.spc), [tc.cws.NX, tc.cws.NY]);
            
            tc.cws = CWSpc('demo2D');
            tc.assertTrue(tc.cws.is2d);
            tc.assertGreaterThan(tc.cws.NY, 1);
            tc.assertEqual(size(tc.cws.spc), [tc.cws.NX, tc.cws.NY]);
        end
        function testshow(tc)
            % show should plot 1D and 2D separately
        end
        %% assert CWSpc.is1d
        function testnormplot(tc)
            % cws.normplot() is static
            % cws.normplot() should return 'CWSpc:NoArgin'
            % cws.normplot(cws0) return figure with 1 spc
            % cws.normplot(cws0, cws1, ...) return figure with normalized
            % overlapping spcs
            % cws.normplot(..., 'BAlign', false) disable BAlign.
        end
        %% B field drifting correction
        function testbshift(tc)
            % cws.bshift() throws 'CWSpc:NoArgin'
            % cws.bshift(x) return CWSpc: shift B by x;
        end
        function testbdrift(tc)
            % cws.bdrift() throws 'CWSpc:NoArgin'
            % cws.bdrift(cws1) return double: B drift from cws to cws1
        end
        %% Background and Baseline correction
        function testsubtractbg(tc)
            % cws.subtractbg() throws 'CWSpc:NoArgin'
            % cws.subtractbg(cws1):
            %       if cws.sameparams(cws, cws1)
            %               subtract cws1 per scan from cws
            %       else:
            %           throws "CWSpc:NotSameParamsSPC"
            tc.assertError(@()tc.cws.subtractbg(), 'CWSPC:NoArgin');
            tc.assertError(@()tc.cws.subtractbg(tc.cws2D), 'CWSPC:NotSameParams');
            tc.assertEqual(tc.cws.subtractbg(tc.cws).spc, zeros(tc.cws.NX, 1));
        end
        function testscale(tc)
            tc.assertEqual(range(tc.cws.rescale().spc), 1);
            tc.assertError(@()tc.cws2D.rescale(), 'CWSPC:DimError')
        end
        function testsameparams(tc)
            % Static 
            % nargin == 0: throws 'CWSpc:NoArgin'
            % else: 
            % cws.sameparams(cws1) 
            %   true only if cws and cws1 are
            % 1. same dimension
            % 2. same X resolution
            % 3. same acqusition parameters on Hall, MWBridge and Receiver
            tc.assertError(@()tc.cws.sameparams(), 'CWSpc:NoArgin');
            tc.assertTrue(tc.cws.sameparams(tc.cws));
            tc.assertTrue(tc.cws2D.sameparams(tc.cws2D));
            tc.assertFalse(tc.cws.sameparams(tc.cws2D));
        end
        function testallsameparams(tc)
            cwss = [tc.cws, tc.cws, tc.cws];
            tc.assertTrue(CWSpc.allsameparams(cwss));
            cwss(3).acqParams.CenterField = 3489;
            tc.assertFalse(CWSpc.allsameparams(cwss));
        end
        
        %% assert CWSpc.is2d
        function testmean(tc)
            % cws.mean(): Return 1D CWS of averaged intensity per scan
            % if cws.is1d and nagrin == 0:
            %    Return Intensity/(nX*nY)
            % elseif cws.is1d and nargin > 0:
            %   throw 'CWSpc:TooManyArgin'
            % elseif cws.is2d and nargin == 0:
            %   Return cws.sum(scans).mean()
            
            %1D mean
            tc.assertEqual(tc.cws.mean().spc, tc.cws.spc);
            tc.assertTrue(tc.cws.mean().sameparams(tc.cws));
            %2D mean
            tc.assertEqual(tc.cws2D.mean().spc, mean(tc.cws2D.spc, 2));
            tc.assertTrue(tc.cws2D.mean().is1d);
            tc.assertEqual(tc.cws2D.mean(1:100).spc, mean(tc.cws2D.spc(:, 1:100), 2));
        end
        function testsum(tc)
            % cws.sum(): Return 1D CWS by sum-up all spc at 2nd dim
            % cws.sum([1, 3:10]): Return 1D CWS by sum-up spc of the given
            %           scans.
            % if cws.is1d: return cws, do nothing
            
            %1D sum
            tc.assertEqual(tc.cws.sum().spc, tc.cws.spc);
            %2D sum all
            tc.assertTrue(tc.cws2D.sum().is1d);
            tc.assertEqual(tc.cws2D.sum().spc, sum(tc.cws2D.spc, 2));
            %2D sum slices
            cws = tc.cws2D.sum(1:100);
            tc.assertTrue(cws.is1d);
            tc.assertEqual(cws.NScan, tc.cws2D.NScan * 100);
            tc.assertEqual(tc.cws2D.sum(1:100).spc, sum(tc.cws2D.spc(:, 1:100), 2));
        end
            
    end
end