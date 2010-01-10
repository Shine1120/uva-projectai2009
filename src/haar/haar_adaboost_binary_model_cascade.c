
/*

  Haar adaboost classifier for binary problem

  Usage
  ------

  model = haar_adaboost_binary_model_cascade(II , y , [rect_param] , [F] , [T] , [options] , [premodel]);

  
  Inputs
  -------

  II                                    Images Integral (Ny x Nx x N) standardized in DOUBLE format

  y                                     Binary labels (1 x N), y[i] = {-1 , 1} in INT8 format

  rect_param                            Features rectangles parameters (10 x nR), where nR is the total number of rectangles for the patterns.
                                        (default Vertical(2 x 1) [1 ; -1] and Horizontal(1 x 2) [-1 , 1] patterns) 
										rect_param(: , i) = [ip ; wp ; hp ; nrip ; nr ; xr ; yr ; wr ; hr ; sr], where
										ip     index of the current pattern. ip = [1,...,nP], where nP is the total number of patterns
										wp     width of the current pattern
										hp     height of the current pattern
										nrip   total number of rectangles for the current pattern ip
										nr     index of the current rectangle of the current pattern, nr=[1,...,nrip]
										xr,yr  top-left coordinates of the current rectangle of the current pattern
										wr,hr  width and height of the current rectangle of the current pattern
										sr     weights of the current rectangle of the current pattern 

  F                                     Features's list (6 x nF) in UINT32 where nF designs the total number of Haar features
                                        F(: , i) = [if ; xf ; yf ; wf ; hf ; ir]
										if     index of the current feature, if = [1,....,nF] where nF is the total number of Haar features  (see nbfeat_haar function)
										xf,yf  top-left coordinates of the current feature of the current pattern
										wf,hf  width and height of the current feature of the current pattern
										ir     index of rectangle definition of the current feature in rect_param

  T                                     Number of weak learners (default T = 100)
  options
              weaklearner               Choice of the weak learner used in the training phase
			                            weaklearner = 2 <=> minimizing the weighted error : sum(w * |z - h(x;(th,a))|), where h(x;(th,a)) = a*sign(z - th)  in [-1,1] for discrete adaboost



  premodel                              Classifier's premodels parameter up to n-1 stage (4 x Npremodels)(default premodel = [] for stage n=1)

  Outputs
  -------


  
  Model                                 Model output (4 x T) for current stage n of the classifier's premodel
              featureIdx                Feature indexes of the T best weaklearners (1 x T)
			  th                        Optimal Threshold parameters (1 x T)
			  a                         WeakLearner's weights (1 x T) in R (at = ct*pt, where pt = polarity)
			  b                         Zeros (1 x T), i.e. b = zeros(1 , T)




  To compile
  ----------


  mex  -output haar_adaboost_binary_model_cascade.dll haar_adaboost_binary_model_cascade.c

  mex  -f mexopts_intel10amd.bat -output haar_adaboost_binary_model_cascade.dll haar_adaboost_binary_model_cascade.c



  Example 1
  ---------


  load viola_24x24
  load haar_dico_2

  II                 = image_integral_standard(X);
  [Ny , Nx , P]      = size(II);
  T                  = 1;
  F                  = haar_featlist(Ny , Nx , rect_param);

  index              = randperm(length(y));
  
  N                  = 1000;
  vect               = [1:N , 5000:5000+N];
  index              = vect(randperm(length(vect)));
  index              = randperm(length(y));

  y                  = int8(y);
  z                  = haar(X(: , : , index) , rect_param , F(: , 1));
  tic,model          = haar_adaboost_binary_model_cascade(II(: , : , index) , y(index) , rect_param , F , T);,toc
  [yest , fx]        = haar_adaboost_binary_predict_cascade(II , model , rect_param , F);
  indp               = find(y == 1);
  indn               = find(y ==-1);

  tp                 = sum(yest(indp) == y(indp))/length(indp)
  fp                 = 1 - sum(yest(indn) == y(indn))/length(indn)
  perf               = sum(yest == y)/length(y)

  [tpp , fpp]        = basicroc(y , fx);

  figure(1)
  plot(fpp , tpp)
  axis([-0.02 , 1.02 , -0.02 , 1.02])


  [dum , ind]        = sort(y , 'descend');
  figure(2)
  plot(fx(ind))




  Example 2
  ---------

  clear, close all 
  load viola_24x24
  load haar_dico_2

  II                 = image_integral_standard(X);
  [Ny , Nx , P]      = size(II);
  T                  = 5;
  Nimage             = 110;
  nb_feats           = 5;

  F                  = haar_featlist(Ny , Nx , rect_param);

  index              = randperm(length(y));
  
  y                  = int8(y);
  tic,model          = haar_adaboost_binary_model_cascade(II(: , : , index) , y(index) , rect_param , F , T);,toc
  [yest , fx]        = haar_adaboost_binary_predict_cascade(II , model , rect_param , F);
  indp               = find(y == 1);
  indn               = find(y ==-1);

  tp                 = sum(yest(indp) == y(indp))/length(indp)
  fp                 = 1 - sum(yest(indn) == y(indn))/length(indn)
  perf               = sum(yest == y)/length(y)

  [tpp , fpp]        = basicroc(y , fx);

  figure(1)
  plot(fpp , tpp)
  axis([-0.02 , 1.02 , -0.02 , 1.02])


  [dum , ind]        = sort(y , 'descend');
  figure(2)
  plot(fx(ind))


  I                  = X(: , : , Nimage);


  figure(3)
  imagesc(I)
  hold on

  best_feats          = (F(: , model(1 , 1:nb_feats)));
  x                   = double(best_feats(2 , :)) + 0.5 ;	
  y                   = double(best_feats(3 , :)) + 0.5;
  w                   = best_feats(4 , :);
  h                   = best_feats(5 , :);
  indR                = fix(best_feats(6 , :) + 1)/10 + 1;
  R                   = rect_param(4 , indR);
  
    for f = 1 : nb_feats
     for r = 0:R(f)-1
 		
  		coeffw  = w(f)/rect_param(2 , indR(f) + r);		
  		coeffh  = h(f)/rect_param(3 , indR(f) + r);
  		xr      = (x(f) + double(coeffw*rect_param(6 , indR(f) + r)));
  		yr      = (y(f) + double(coeffh*rect_param(7 , indR(f) + r))) ;
  		wr      = double(coeffw*(rect_param(8 , indR(f) + r)  - 0));
  		hr      = double(coeffh*(rect_param(9 , indR(f) + r) - 0));
  		s       = rect_param(10 , indR(f) + r);
  		if (s == 1)
            
  			color   = [0.9 0.9 0.9];
          
          else
  
    	    color   = [0.1 0.1 0.1];
  
          end
  	    hh      = rectangle('Position', [xr,  yr ,  wr ,  hr] );
        p       = patch([xr , xr+wr , xr + wr , xr] , [yr , yr , yr + hr , yr + hr] , color);
  		alpha(p , 0.8);
  	    set(hh , 'linewidth' , 2 , 'EdgeColor' , [1 0 0])
  
  	end
   end
    hold off
  
    title(sprintf('Best %d Haar features' , nb_feats) , 'fontsize' , 13)
    colormap(gray)




 Author : Sébastien PARIS : sebastien.paris@lsis.org
 -------  Date : 01/27/2009

 Reference  : [1] R.E Schapire and al "Boosting the margin : A new explanation for the effectiveness of voting methods". 
 ---------        The annals of statistics, 1999

              [2] Zhang, L. and Chu, R.F. and Xiang, S.M. and Liao, S.C. and Li, S.Z, "Face Detection Based on Multi-Block LBP Representation"
			      ICB07

			  [3] C. Huang, H. Ai, Y. Li and S. Lao, "Learning sparse features in granular space for multi-view face detection", FG2006
 
			  [4] P.A Viola and M. Jones, "Robust real-time face detection", International Journal on Computer Vision, 2004


*/


#include <time.h>
#include <math.h>
#include "mex.h"


#define huge 1e300
#define sign(a) ((a) >= (0) ? (1.0) : (-1.0))


struct opts
{

  int    weaklearner;

};



/* Function prototypes */


int number_haar_features(int , int , double * , int );

void haar_featlist(int , int , double * , int  , unsigned int * );

double Area(double * , int , int , int , int , int );

double haar_feat(double *  , int  , double * , unsigned int * , int , int , int );

void qsindex( double * , int * , int , int  );


void  adaboost_decision_stump(double * , char * , double *  , unsigned int *   , int , struct opts  , double * , int , 
		                      double * ,
		                      int , int , int , int , int );


/*---------------------------------------------------------------------------------------------------------------------------------------------------- */



void mexFunction( int nlhs, mxArray *plhs[] , int nrhs, const mxArray *prhs[] )

{
		
    double *II;
	
	char *y;

	const int *dimsII;
	
    unsigned int *F;

	double *rect_param;

	double	rect_param_default[40] = {1 , 1 , 2 , 2 , 1 , 0 , 0 , 1 , 1 , 1 , 1 , 1 , 2 , 2 , 2 , 0 , 1 , 1 , 1 , -1 , 2 , 2 , 1 , 2 , 1 , 0 , 0 , 1 , 1 , -1 , 2 , 2 , 1 , 2 , 2 , 1 , 0 , 1 , 1 , 1};

	double *premodel=NULL;



	double *model;

	
	int i , Ny , Nx , N , nR , nF , T=100 , Npremodel = 0; 

	mxArray *mxtemp;


	struct opts options = {2};
	
		
	double *tmp;
	
	int tempint;
	
	
	
    /* Input 1  */
	
	if( (mxGetNumberOfDimensions(prhs[0]) ==3) && (!mxIsEmpty(prhs[0])) && (mxIsDouble(prhs[0])) )
	{
		
		II          = mxGetPr(prhs[0]);

		dimsII      = mxGetDimensions(prhs[0]);
		
		Ny          = dimsII[0];
		
		Nx          = dimsII[1];

		N           = dimsII[2];
			
	}
	
	else
	{
		mexErrMsgTxt("Integral Image II must be (Ny x Nx x N) in DOUBLE format");
			
	}
	
	
	
	/* Input 2  */
	
	if ( (nrhs > 1) && (!mxIsEmpty(prhs[1])) && (mxIsInt8(prhs[1])) )
		
	{		
		y        = (char *)mxGetData(prhs[1]);	
	}

	else
	{
		mexErrMsgTxt("y must be (1 x N) in INT8 format");
			
	}


    /* Input 3  */


    if ((nrhs > 2) && !mxIsEmpty(prhs[2]) )
    {
        
        if( mxGetNumberOfDimensions(prhs[2]) !=2 )
        {
            
            mexErrMsgTxt("rect_param must be (10 x nR)");
            
        }
        
        
        if(mxGetM(prhs[2]) != 10)
        {
            
            mexErrMsgTxt("rect_param must be (10 x nR)");
            
        }

        rect_param  = mxGetPr(prhs[2]);

		nR          = mxGetN(prhs[2]);
		
       
    }
    else
    {
        
		rect_param     = (double *)mxMalloc(40*sizeof(double));

		for (i = 0 ; i < 40 ; i++)
		{
			
			rect_param[i]    = rect_param_default[i];

		}			
    }   
	

    /* Input 4  */
    
    if ((nrhs > 3) && !mxIsEmpty(prhs[3]) && mxIsUint32(prhs[3]) )
        
    {        
        F        = (unsigned int *) mxGetData(prhs[3]);
		
		nF       = mxGetN(prhs[3]);
        
    }
	else
	{
		
		nF       = number_haar_features(Ny , Nx , rect_param , nR);
				
		F        = (unsigned int *)mxMalloc(6*nF*sizeof(int));
        
		haar_featlist(Ny , Nx , rect_param , nR , F );
		
	}
	
	/* Input 5  */
	
	
	if ((nrhs > 4) && !mxIsEmpty(prhs[4]) )
		
	{
		T          = (int) mxGetScalar(prhs[4]);		
	}
	
	
	
	/* Input 6  */
	
	
	if ((nrhs > 5) && !mxIsEmpty(prhs[5]) )
		
	{
		
		mxtemp                            = mxGetField(prhs[5] , 0 , "weaklearner");
		
		if(mxtemp != NULL)
		{
			
			tmp                           = mxGetPr(mxtemp);
			
			tempint                       = (int) tmp[0];
			
			if((tempint < 2) || (tempint > 3))
			{
				
				mexErrMsgTxt("weaklearner = {2}, force to 2");	
				
				options.weaklearner       = 2;
				
			}
			else
			{
				
				options.weaklearner        = tempint;
				
			}	
		}		
	}

	/* Input 7  */

	if ((nrhs > 6) && !mxIsEmpty(prhs[6]) )
	{
		

		premodel      =  mxGetPr(prhs[6]);

		if(mxGetM(prhs[6]) != 4)
		{
		
			mexErrMsgTxt("premodel must be (4 x Npremodel) in double format");

		}
		
		Npremodel     = mxGetN(prhs[6]);
	}


		/*------------------------ Main Call ----------------------------*/

	if(options.weaklearner == 2)
	{
		
			
		plhs[0]              = mxCreateNumericMatrix(4 , T , mxDOUBLE_CLASS,mxREAL);
		
		model                = mxGetPr(plhs[0]);
		
		
		adaboost_decision_stump(II , y , rect_param , F  , T , options , premodel , Npremodel , 
			                    model,
			                    Ny , Nx , N , nR , nF);
		
	}
	

    if((nrhs < 3) || mxIsEmpty(prhs[2]) )
	{
		
        mxFree(rect_param);
		
	}

    if ((nrhs < 4) || mxIsEmpty(prhs[3]) )        
    {

		mxFree(F);
        
    }
}


/*----------------------------------------------------------------------------------------------------------------------------------------- */

void  adaboost_decision_stump(double *II , char *y , double *rect_param , unsigned int *F  , int T , struct opts options , double *premodel , int Npremodel , 
							  double *model ,
							  int Ny , int Nx , int N , int nR , int nF)
								 								 
{
		
	int i , j , t;
	
	int NyNx = Ny*Nx , indNyNx , indM  , ind , N1 = N - 1 , featuresIdx_opt;

	double cteN =1.0/(double)N  , Tplus , Tminus , Splus , Sminus , Errormin , errm , fm , sumw , cm , Errplus , Errminus , wtemp , a_opt ;
		
	double *w;

	char ytemp;
	
	double *xtemp , z , th_opt ;

	char  *h;
	
	int *index;
	
	
	
	xtemp               = (double *)mxMalloc(N*sizeof(double ));
		
	index               = (int *)mxMalloc(N*sizeof(int));
	
	w                   = (double *)mxMalloc(N*sizeof(double));

	h                   = (char *)mxMalloc(N*sizeof(char));
	
	
	for(i = 0 ; i < N ; i++)
	{
		
		w[i]  = cteN;
		
	}

	/* Previous premodel */
	
	indM                 = 0;
	
	for(j = 0 ; j < Npremodel ; j++)
	{
		
		featuresIdx_opt  = ((int) premodel[0 + indM]) - 1;
		
		th_opt           = premodel[1 + indM];
		
		a_opt            = premodel[2 + indM];
				
				
		sumw             = 0.0;

		indNyNx          = 0;
		
		for (i = 0 ; i < N ; i++)
		{
		    z            = haar_feat(II + indNyNx , featuresIdx_opt , rect_param , F , Ny , nR , nF);
			
			fm           = a_opt*sign(z - th_opt);
			
			w[i]        *= exp(-y[i]*fm);
			
			sumw        += w[i];

            indNyNx     += NyNx;

		}
		
		
		sumw            = 1.0/sumw;
		
		for (i = 0 ; i < N ; i++)
		{
			
			w[i]         *= sumw;
		}
		
		indM            += 4;
		
	}
	
	
	indM  = 0;
	
	for(t = 0 ; t < T ; t++)
		
	{		
		Errormin         = huge;
		
		Tplus            = 0.0;
		
		Tminus           = 0.0;

		for(i = 0 ; i < N ; i++)				
		{
			
			if(y[i] == 1)
			{
				
				Tplus    += w[i];
				
			}				
			else
			{
				
				Tminus   += w[i];
				
			}								
		}
		
		
		for(j = 0 ; j < nF  ; j++)
			
		{			
			
			if((j%1000) == 1)
			{
				mexPrintf("%d/%d\n" , t+1 , j);
			}
			
			
			indNyNx          = 0;
					
			for(i = 0 ; i < N ; i++)				
			{
				
				index[i]     = i;
				
				xtemp[i]     = haar_feat(II + indNyNx , j , rect_param , F , Ny , nR , nF);
				
				indNyNx     += NyNx;

			}
			
			
			qsindex(xtemp , index , 0 , N1);


			Splus            = 0.0;
			
			Sminus           = 0.0;

			
						
			for(i = 0 ; i < N ; i++)
				
			{
				
				ind         = index[i];
				
				ytemp       = y[ind];
				
				wtemp       = w[ind];
				
				Errplus     = Splus  + (Tminus - Sminus);
				
				Errminus    = Sminus + (Tplus - Splus);
				
				if(Errplus  < Errormin)
				{
					
					Errormin        = Errplus;
					
					if(i < N1)
					{
						
						th_opt      = (xtemp[i] + xtemp[i + 1])/2;
						
					}
					else
					{
						
						th_opt      = xtemp[i];
						
					}
					
					featuresIdx_opt = j;
					
					a_opt           = 1.0;
					
				}
				
				if(Errminus <= Errormin)
				{
					
					Errormin        = Errminus;
					
					if(i < N1)
					{
						
						th_opt      = (xtemp[i] + xtemp[i + 1])/2;
						
					}
					else
					{
						
						th_opt      = xtemp[i];
						
					}
					
					featuresIdx_opt = j;
					
					a_opt           = -1.0;
					
				}
				
				if(ytemp == 1)
				{
					
					Splus  += wtemp;
					
				}
				else
					
				{
					
					Sminus += wtemp;
					
				}	
			}
					
		}
		
		
		indNyNx          = 0;

		errm             = 0.0;
		
		for (i = 0 ; i < N ; i++)
		{
			
		    z            = haar_feat(II + indNyNx , featuresIdx_opt , rect_param , F , Ny , nR , nF);

			h[i]         = a_opt*sign(z - th_opt);

			if(y[i] != h[i])
			{

				errm    += w[i];

			}

			indNyNx     += NyNx;

		}

	
		cm              = 0.5*log((1.0 - errm)/errm);

		sumw            = 0.0;

		for (i = 0 ; i < N ; i++)

		{
			w[i]        *= exp(-y[i]*h[i]*cm);
			
			sumw        += w[i];

		}
		
		
		sumw            = 1.0/sumw;
		
		for (i = 0 ; i < N ; i++)
		{
			
			w[i]         *= sumw;
		}


		model[0 + indM]  = (double) (featuresIdx_opt + 1);
		
		model[1 + indM]  = th_opt;
		
		model[2 + indM]  = a_opt*cm;
		
		model[3 + indM]  = 0.0;
		
		indM            += 4;
				
	}
	

	mxFree(w);
	
	mxFree(index);
	
	mxFree(xtemp);
		
	mxFree(h);
	
}



/*----------------------------------------------------------------------------------------------------------------------------------------- */



double haar_feat(double *II , int featidx , double *rect_param , unsigned int *F , int Ny , int nR , int nF)
{
	
	int x , xr , y , yr , w , wr , h , hr , r , s  ,  R , indR , indF = featidx*6;
	
	int coeffw , coeffh;
	
	double val = 0.0;
	
	x     = F[1 + indF];
	
	y     = F[2 + indF];

	w     = F[3 + indF];

	h     = F[4 + indF];
	
	indR  = F[5 + indF];
	
	R     = (int) rect_param[3 + indR];
	
	
	for (r = 0 ; r < R ; r++)
	{
		
		coeffw  = w/(int)rect_param[1 + indR];
		
		coeffh  = h/(int)rect_param[2 + indR];
		
		xr      = x + coeffw*(int)rect_param[5 + indR];
		
		yr      = y + coeffh*(int)rect_param[6 + indR];
		
		wr      = coeffw*(int)(rect_param[7 + indR]);
		
		hr      = coeffh*(int)(rect_param[8 + indR]);
		
		s       = rect_param[9 + indR];
		
		val    += s*Area(II , xr  , yr  , wr , hr , Ny);
		
		indR   += 10;
		
	}
	
	return val;		
	
}



/*----------------------------------------------------------------------------------------------------------------------------------------- */

void qsindex (double  *a, int *index , int lo, int hi)
{
/*  lo is the lower index, hi is the upper index
  of the region of array a that is to be sorted

*/
    int i=lo, j=hi , ind;

    double x=a[(lo+hi)/2] , h;

    do
    {    
        while (a[i]<x) i++; 
        while (a[j]>x) j--;
        if (i<=j)
        {
            h        = a[i]; 
			a[i]     = a[j]; 
			a[j]     = h;
			ind      = index[i];
			index[i] = index[j];
			index[j] = ind;
            i++; 
			j--;
        }
    }
	while (i<=j);

    if (lo<j) qsindex(a , index , lo , j);
    if (i<hi) qsindex(a , index , i , hi);
}



/*----------------------------------------------------------------------------------------------------------------------------------------- */



void haar_featlist(int ny , int nx , double *rect_param , int nR , 
				   unsigned int *F )
{
	
	int  r , indF = 0 , indrect = 0 , currentfeat = 0 , temp , W , H , w , h , x , y;

	int nx1 = nx + 1, ny1 = ny + 1;
	
	for (r = 0 ; r < nR ; r++)
	{
		
		temp            = (int) rect_param[0 + indrect];
		
		if(currentfeat != temp)
		{
			currentfeat = temp;
			
			W           = (int) rect_param[1 + indrect];

			H           = (int) rect_param[2 + indrect];
				
			for(w = W ; w < nx1 ; w +=W)
			{
				for(h = H ; h < ny1 ; h +=H)
					
				{
					for(y = 0 ; y + h < ny1 ; y++)
					{
						for(x = 0 ; x + w < nx1 ; x++)
						{
							
							F[0 + indF]   = currentfeat;
							
							F[1 + indF]   = x;
							
							F[2 + indF]   = y;
							
							F[3 + indF]   = w;
							
							F[4 + indF]   = h;
							
							F[5 + indF]   = indrect;
							
							indF         += 6;
							
						}
					}
				}
			}
			
		}
		
		indrect        += 10;		
	}
}


/*----------------------------------------------------------------------------------------------------------------------------------------- */


int number_haar_features(int ny , int nx , double *rect_param , int nR)
{
	int i , temp , indrect = 0 , currentfeat = 0 , nF = 0 , h , w;
	
	int Y , X ;
	
	int nx1 = nx + 1, ny1 = ny + 1;
	
	for (i = 0 ; i < nR ; i++)
	{
		temp            = (int) rect_param[0 + indrect];
		
		if(currentfeat != temp)
		{
			currentfeat = temp;
			
			w           = (int) rect_param[1 + indrect];
			
			h           = (int) rect_param[2 + indrect];
			
			X           = (int) floor(nx/w);
			
			Y           = (int) floor(ny/h);
			
			nF         += (int) (X*Y*(nx1 - w*(X+1)*0.5)*(ny1 - h*(Y+1)*0.5));
			
		}
		
		indrect   += 10;
	}
		
	return nF;
	
}

/*----------------------------------------------------------------------------------------------------------------------------------------- */

double Area(double *II , int x , int y , int w , int h , int Ny)
{
	
	int h1 = h-1 , w1 = w-1 , x1 = x-1, y1 = y-1;
	
	
	if( (x == 0) && (y==0))
	{
		
		return (II[h1 + w1*Ny]);
		
	}
	if( (x==0) ) 
	{
		return(II[(y+h1) + w1*Ny] - II[y1 + w1*Ny]);
		
	}
	
	if( (y==0) ) 
	{
		
		return(II[h1 + (x+w1)*Ny] - II[h1 + x1*Ny]);
		
	}
	
	else
	{
		
		return (II[(y+h1) + (x+w1)*Ny] - (II[y1 + (x+w1)*Ny] + II[(y+h1) + x1*Ny]) + II[y1 + x1*Ny]);
	}
	
}
/*----------------------------------------------------------------------------------------------------------------------------------------- */
