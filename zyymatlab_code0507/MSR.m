function [RMS] = MSR(signal,num)
                square= signal.* signal;
                sumsquare=sum(square);
                ms=sumsquare/num;
                RMS=ms^0.5;
end

