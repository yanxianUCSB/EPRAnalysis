classdef CWSpcTest < matlab.unittest.TestCase
    properties
        cws
    end
    methods
        function obj = CWSpcTest()
        end
        function testcwspc(tc)
            tc.cws = CWSpc('demo1D');
            tc.assertTrue(tc.cws.is1d);
            
            tc.cws = CWSpc('demo2D');
            tc.assertTrue(tc.cws.is2d);
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
        function testbshift(tc)
            % cws.bshift() throws 'CWSpc:NoArgin'
            % cws.bshift(x) return CWSpc: shift B by x;
        end
        function testbdrift(tc)
            % cws.bdrift() throws 'CWSpc:NoArgin'
            % cws.bdrift(cws1) return double: B drift from cws to cws1
        end
        function testsubtractbg(tc)
            % cws.subtractbg() throws 'CWSpc:NoArgin'
            % cws.subtractbg(cws1):
            %       if cws.sameparams(cws, cws1)
            %               subtract cws1 per scan from cws
            %       else:
            %           throws "CWSpc:NotSameParamsSPC"
        end
        function testsameparams(tc)
            % Static 
            % nargin == 0: throws 'CWSpc:NoArgin'
            % nargin == 1 && argin is array of length < 1 or not array:
            %               return true
            % else: 
            % cws.sameparams(cws0, cws1, cws2, ...) or
            % cws.sameparams([cws0, cws1, cws2, ...])
            %   return bool: all acqusition params identical: MW, Gain,
            %   Modulation
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
        end
        function testsum(tc)
            % cws.sum(): Return 1D CWS by sum-up all spc at 2nd dim
            % cws.sum([1, 3:10]): Return 1D CWS by sum-up spc of the given
            %           scans.
            % if cws.is1d: return cws, do nothing
        end
            
            
    end
end