
/*

  Eval Haar features cascade trained model on a set of image X

  Usage
  ------

  fx         = eval_haar(X , model , [cascade] , [standardize]);

  
  Inputs
  -------

  I                                     Input images (Ny x Nx x N) in UINT8 format.
  
  model                                 Trained model structure
             weaklearner                Choice of the weak learner used in the training phase (default weaklearner = 2)
			                            weaklearner = 0 <=> minimizing the weighted error : sum(w * |z - h(x;(th,a,b))|^2) / sum(w), where h(x;(th,a,b)) = (a*(x>th) + b) in R
			                            weaklearner = 1 <=> minimizing the weighted error : sum(w * |z - h(x;(a,b))|^2), where h(x;(a,b)) = sigmoid(x ; a,b) in R
			                            weaklearner = 2 <=> minimizing the weighted error : sum(w * |z - h(x;(th,a))|), where h(x;(th,a)) = a*sign(z - th)  in [-1,1] for discrete adaboost

             param                      Trainned classfier parameters matrix (4 x T). Each row corresponds to :

                                        featureIdx                Feature indexes of the T best weaklearners (1 x T)
			                            th                        Optimal Threshold parameters (1 x T)
			                            a                         WeakLearner's weights (1 x T) in R (at = ct*pt, where pt = polarity when weaklearner = 2)
			                            b                         Offset (1 x T) (when weaklearner = 2, b = 0)

			 dimsItraining              Size of the train images used in the haar computation, i.e. (ny x nx )

             rect_param                 Features rectangles parameters (10 x nR), where nR is the total number of rectangles for the patterns.
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

             F                          Features's list (6 x nF) in UINT32 where nF designs the total number of Haar features
                                        F(: , i) = [if ; xf ; yf ; wf ; hf ; ir]
										if     index of the current feature, if = [1,....,nF] where nF is the total number of Haar features  (see nbfeat_haar function)
										xf,yf  top-left coordinates of the current feature of the current pattern
										wf,hf  width and height of the current feature of the current pattern
										ir     index of rectangle definition of the current feature in rect_param

             cascade_type               Type of cascade structure : 0 for coventional cascade, 1 for multi-exit cascade
	
 
  cascade                               Cascade parameters (2 x Ncascade) where cascade(1 , :) represents Entrance/Exit nodes.

                                        If cascade_type = 0, i.e. coventional cascade, Entrance nodes are [1 , cumsum(cascade(1 , 1:end-1))+1] and exit nodes are cumsum(cascade(1 , :)) 
										If cascade_type = 1, i.e. multi-exit cascade, Entrance node is 1, exit nodes are cumsum(cascade(1 , :))
										
										cascade(2 , :) reprensent thresholds for each segment
  
  standardize                           Standardize Input Images 1 = yes, 0 = no (default = 1)



  Outputs
  -------
  
  fx                                    Output matrix (1 x V) of the last stage/Strong classifier (cascade_type = 0/1) 

  To compile
  ----------


  mex  -output eval_haar.dll eval_haar.c

  mex  -f mexopts_intel10.bat -output eval_haar.dll eval_haar.c


  Example 1    Viola-Jones database
  ---------


  load viola_24x24.mat
  load model_detector_haar_24x24.mat
  %load model_detector_haar_24x24_wl2_ct0_nP19.mat
  cascade          = [5 , 10 , 20 , 30 , 35 ; -1.5 ,  -0.75 ,  -0.5 , -0.25 , 0];
  thresh           = 0;

  indp             = find(y == 1);
  indn             = find(y ==-1);

  fx_cascade       = eval_haar(X , model , cascade);
  yest             = int8(sign(fx_cascade));


  tp               = sum(yest(indp) == y(indp))/length(indp)
  fp               = 1 - sum(yest(indn) == y(indn))/length(indn)
  perf             = sum(yest == y)/length(y)
  [tpp1 , fpp1 ]   = basicroc(y , fx_cascade);



  fx               = eval_haar(X , model);
  yest             = int8(sign(fx - thresh));


  tp               = sum(yest(indp) == y(indp))/length(indp)
  fp               = 1 - sum(yest(indn) == y(indn))/length(indn)
  perf             = sum(yest == y)/length(y)
  [tpp2 , fpp2 ]   = basicroc(y , fx);


  figure(1)
  plot(1:length(y) , fx , 'r' , 1:length(y) , fx_cascade , 'b')
  
  figure(2)
  plot(fpp1 , tpp1 , fpp2 , tpp2 , 'r')
  axis([-0.02 , 1.02 , -0.02 , 1.02])
  legend('Cascade' , 'No Cascade')
  title('HAAR')





  Example 2    Viola-Jones database : incorporing more Features pattern
  ---------

  clear
  load viola_24x24.mat
  load model_detector_haar_24x24.mat
  thresh           = 0;

  indp             = find(y == 1);
  indn             = find(y ==-1);



  fx1              = eval_haar(X , model);
  yest             = int8(sign(fx1 - thresh));


  tp               = sum(yest(indp) == y(indp))/length(indp)
  fp               = 1 - sum(yest(indn) == y(indn))/length(indn)
  perf             = sum(yest == y)/length(y)
  [tpp1 , fpp1 ]   = basicroc(y , fx1);


  load model_detector_haar_24x24_wl2_ct0_nP19.mat

  fx2              = eval_haar(X , model);
  yest             = int8(sign(fx2 - thresh));



  tp               = sum(yest(indp) == y(indp))/length(indp)
  fp               = 1 - sum(yest(indn) == y(indn))/length(indn)
  perf             = sum(yest == y)/length(y)
  [tpp2 , fpp2 ]   = basicroc(y , fx2);


  figure(1)
  plot(1:length(y) , fx1 , 'b' , 1:length(y) , fx2 , 'r')
  legend('2 patterns' , '19 patterns')

  
  figure(2)
  plot(fpp1 , tpp1 , fpp2 , tpp2 , 'r')
  axis([-0.02 , 1.02 , -0.02 , 1.02])
  legend('2 patterns' , '19 patterns')
  title('HAAR')




 Author : Sébastien PARIS : sebastien.paris@lsis.org
 -------  Date : 02/20/2009

 Reference ""


*/


#include <time.h>
#include <math.h>
#include <mex.h>

#define max(A,B)   (((A) > (B)) ? (A) : (B) )
#define min(A,B)   (((A) < (B)) ? (A) : (B) ) 
#define sign(a)    ((a) >= (0) ? (1.0) : (-1.0))
 


struct model
{

	int     weaklearner;

	double  epsi;


	double *param;

	int     T;


	double  *dimsItraining;

	int     ny;

	int     nx;


	double  *rect_param;

	int     nR;


	unsigned int  *F;

	int     nF;

	int     cascade_type;


};


/* Function prototypes */


int number_haar_features(int , int , double * , int );

void haar_featlist(int , int , double * , int  , unsigned int * );

unsigned int Area(unsigned int * , int , int , int , int , int );

double haar_feat(unsigned int *  , int  , double * , unsigned int * , int , int , int );


void MakeIntegralImage(unsigned char *, unsigned int *, int , int , unsigned int *);


void eval_haar(unsigned char * , int , int , int , struct model  , double * , int  , int , 
			   double *);



/*-------------------------------------------------------------------------------------------------------------- */

void mexFunction( int nlhs, mxArray *plhs[] , int nrhs, const mxArray *prhs[] )

{
    
    
    unsigned char *I;

    double *cascade;
	
	struct model detector;
    
    const int *dimsI ;
    
    int numdimsI , Ncascade = 1 , standardize = 1 , Tcascade = 0;
    
    double *fx;

	double	rect_param_default[40] = {1 , 1 , 2 , 2 , 1 , 0 , 0 , 1 , 1 , 1 , 1 , 1 , 2 , 2 , 2 , 0 , 1 , 1 , 1 , -1 , 2 , 2 , 1 , 2 , 1 , 0 , 0 , 1 , 1 , -1 , 2 , 2 , 1 , 2 , 2 , 1 , 0 , 1 , 1 , 1};

	
	mxArray *mxtemp;
	    
    int i , Ny , Nx , V = 1  , tempint;
	
	double *tmp;
	
	
	detector.weaklearner  = 0; 
	
	detector.epsi         = 0.1;

    detector.nR           = 4;

	detector.cascade_type = 0;

	
	
	
    if ((nrhs < 2))       
    {
		
        mexErrMsgTxt("At least 2 inputs are requiered for detector");
		
	}
	

    /* Input 1  */

	
    dimsI                               = mxGetDimensions(prhs[0]);

    numdimsI                            = mxGetNumberOfDimensions(prhs[0]);
    
    if( mxIsEmpty(prhs[0]) || !mxIsUint8(prhs[0]) )
    {
        
        mexErrMsgTxt("I must be (Ny x Nx x N) in UINT8 format");
        
    }

    Ny          = dimsI[0];  
    Nx          = dimsI[1];

	if(numdimsI > 2)
	{

		V       = dimsI[2];

	}
    
    
    I                                     = (unsigned char *)mxGetData(prhs[0]); 
 
    
    /* Input 2  */
    
    if ((nrhs > 1) && !mxIsEmpty(prhs[1]) )
        
    {

		mxtemp                            = mxGetField( prhs[1] , 0, "weaklearner" );

		
		if(mxtemp != NULL)
		{
			
			tmp                           = mxGetPr(mxtemp);
			
			tempint                       = (int) tmp[0];
			
			if((tempint < 0) || (tempint > 3))
			{
				
				mexPrintf("weaklearner = {0,1,2}, force to 2");	
				
				detector.weaklearner      = 2;
				
			}
			else
			{
				
				detector.weaklearner      = tempint;
				
			}			
		}

		mxtemp                            = mxGetField( prhs[1] , 0, "epsi" );

		
		if(mxtemp != NULL)

		{
			tmp                           = mxGetPr(mxtemp);

			if(tmp[0] < 0.0 )
			{
				
				mexPrintf("epsi must be > 0, force to 0.1");	
				
				detector.epsi             = 0.1;
				
			}
			else
			{
				
				detector.epsi             = tmp[0];
				
			}			
		}



		mxtemp                             = mxGetField( prhs[1], 0, "param" );
		
		if(mxtemp != NULL)
		{
			
			detector.param                 = mxGetPr(mxtemp);

			detector.T                     = mxGetN(mxtemp);
			
			
		}
		
		mxtemp                             = mxGetField( prhs[1] , 0, "dimsItraining" );
		
		if(mxtemp != NULL)
		{
			detector.dimsItraining         =  mxGetPr(mxtemp);              
			
			detector.ny                    = (int)detector.dimsItraining[0];
			
			detector.nx                    = (int)detector.dimsItraining[1];

			if ((Ny != detector.ny ) || (Nx != detector.nx ))       
			{
				
				mexErrMsgTxt("I must be  ny x nx");
				
			}	
		}

						
		mxtemp                             = mxGetField( prhs[1] , 0, "rect_param" );
		
		if(mxtemp != NULL)
		{
			detector.rect_param            = mxGetPr(mxtemp);              
			
			detector.nR                    = mxGetN(mxtemp);;
						
		}

		else
		{

			detector.rect_param            = (double *)mxMalloc(40*sizeof(double));
			
			for (i = 0 ; i < 40 ; i++)
			{		
				detector.rect_param[i]     = rect_param_default[i];
				
			}			

		}
		
		
		mxtemp                             = mxGetField( prhs[1] , 0, "F" );
		
		if(mxtemp != NULL)
		{
			
			detector.F                     = (unsigned int *) mxGetData(mxtemp);
			
			detector.nF                    = mxGetN(mxtemp);
			
		}
		else
			
		{
			
			detector.nF                    = number_haar_features(Ny , Nx , detector.rect_param , detector.nR);
			
			detector.F                     = (unsigned int *)mxMalloc(5*detector.nF*sizeof(unsigned int));

			haar_featlist(Ny , Nx , detector.rect_param , detector.nR , detector.F);
			
			
		}

		mxtemp                            = mxGetField( prhs[1] , 0, "cascade_type" );

		if(mxtemp != NULL)
		{
			
			tmp                           = mxGetPr(mxtemp);
			
			tempint                       = (int) tmp[0];
			
			if((tempint < 0) || (tempint > 3))
			{
				
				mexPrintf("cascade_type = {0,1,2}, force to 2");	
				
				detector.cascade_type     = 2;
				
			}
			else
			{
				
				detector.cascade_type     = tempint;
				
			}			
		}			
		
    }
	
	else
		
	{	
		
        mexErrMsgTxt("A detector structure is requiered");
		
	}
    
    

    /* Input 3  */


    if ( (nrhs > 2) && !mxIsEmpty(prhs[2]) )
        
    {
        
		cascade               = mxGetPr(prhs[2]);

		if(mxGetM(prhs[2]) != 2)
		{
			
			mexErrMsgTxt("scalingbox must be (2 x Ncascade)");
				
		}
		

		Ncascade              = mxGetN(prhs[2]);

		for(i = 0 ; i < 2*Ncascade ; i=i+2)
		{
			
			Tcascade         += (int) cascade[i];
			
		}
		
		if(Tcascade > detector.T)
		{
			
			mexErrMsgTxt("sum(cascade(1 , :)) <= T");
			
		}


    }
    
    else
    {
        cascade                = (double *)mxMalloc(2*sizeof(double));
		
		cascade[0]             = (double) detector.T;
		cascade[1]             = 0.0;
       
    }

    /* Input 4  */

    if ((nrhs > 3) && !mxIsEmpty(prhs[3]) )
        
    {        

		standardize            = mxGetScalar(prhs[3]);

	}


    plhs[0]                    = mxCreateDoubleMatrix(1 , V , mxREAL);
    
    fx                         = mxGetPr(plhs[0]);


    
    /*------------------------ Main Call ----------------------------*/
	
	
	eval_haar(I , Ny , Ny , V , detector , cascade , Ncascade , standardize , fx);
	
	
	/*--------------------------- Free memory -----------------------*/
	
     if ( mxIsEmpty(mxGetField( prhs[1] , 0 , "rect_param" )) )
        
    {
        mxFree(detector.rect_param);
        
    }


    if ( mxIsEmpty(mxGetField( prhs[1] , 0 , "F" )) )
        
    {
        mxFree(detector.F);
        
    }
	
	
    if ( (nrhs < 3) || mxIsEmpty(prhs[2]) )		
	{
		
		mxFree(cascade);
	}

}


/*----------------------------------------------------------------------------------------------------------------------------------------- */

void eval_haar(unsigned char *I , int Ny , int Nx , int V , struct model detector  , double *cascade , int Ncascade  , int standardize , double *fx)			   
{
	
    double   *param = detector.param , *rect_param = detector.rect_param;
	
    unsigned int  *II , *Itemp , tempI;

	unsigned int*F = detector.F;
	
	
	int weaklearner = detector.weaklearner , nR = detector.nR , nF = detector.nF , cascade_type = detector.cascade_type;
	
	double epsi = detector.epsi;
	
	double z;
	
	double sum , sum_total , a , b , th , thresc;
	
	int i , v , c , f , Tc , NyNx = Ny*Nx , indNyNx = 0 , indf , indc  , idxF , last = NyNx - 1;

	double  var  , mean , std , cteNyNx = 1.0/NyNx;

	
	
	II                   = (unsigned int *) mxMalloc(NyNx*sizeof(unsigned int));
	Itemp                = (unsigned int *) mxMalloc(NyNx*sizeof(unsigned int));
	
	
	if(standardize)
	{
		for(v = 0 ; v < V ; v++)
		{
					
			MakeIntegralImage(I + indNyNx , II , Nx , Ny  , Itemp);

			var           = 0.0;
			
			for(i = 0 ; i < NyNx ; i++)
			{
				
				tempI      = I[i + indNyNx];		
				var       += (tempI*tempI);
				
			}
			
			var          *= cteNyNx;

			mean          = II[last]*cteNyNx;

			std           = 1.0/sqrt(var - mean*mean);

			
			indf          = 0;
			
			indc          = 0;
			
			sum_total     = 0.0;
			
			for (c = 0 ; c < Ncascade ; c++)
			{
				
				Tc     = (int) cascade[0 + indc];
				
				thresc = cascade[1 + indc];
				
				sum    = 0.0;
				
				for (f = 0 ; f < Tc ; f++)
				{
					
					idxF  = ((int) param[0 + indf] - 1);
					
					
					z     = haar_feat(II , idxF , rect_param , F , Ny , nR , nF);
					
					th    =  param[1 + indf];
					a     =  param[2 + indf];
					b     =  param[3 + indf];
					
					
					if(weaklearner == 0)
						
					{					
						
						sum    += (a*( (z*std) > th ) + b);	
						
					}			
					if(weaklearner == 1)
					{
						
						sum    += ((2.0/(1.0 + exp(-2.0*epsi*(a*(z*std) + b)))) - 1.0);
						
					}
					
					if(weaklearner == 2)
					{
						
						sum    += a*sign((z*std) - th);
						
					}
					
					
					indf      += 4;
					
				}
				
				sum_total     += sum;
				
				if((sum_total < thresc) && (cascade_type == 1))
					
				{
					
					break;
					
				}

				else if(sum < thresc)
					
				{
					
					break;
					
				}

				
				indc      += 2; 
			}
		
			if(cascade_type )
				
			{
				
				fx[v]     = sum_total;
				
			}
			else
			{
					
				fx[v]     = sum;
				
			}
			
					
			indNyNx  += NyNx;
			
		}
		
	}
	else
	{
		for(v = 0 ; v < V ; v++)
		{
			
			
			MakeIntegralImage(I + indNyNx , II , Nx , Ny  , Itemp);
			
			indf          = 0;
			
			indc          = 0;
			
			sum_total     = 0.0;
			
			for (c = 0 ; c < Ncascade ; c++)
			{
				
				Tc     = (int) cascade[0 + indc];
				
				thresc = cascade[1 + indc];
				
				sum    = 0.0;
				
				for (f = 0 ; f < Tc ; f++)
				{
					
					idxF  = ((int) param[0 + indf] - 1);
					
					
					z     = haar_feat(II , idxF , rect_param , F , Ny , nR , nF);
					
					th    =  param[1 + indf];
					a     =  param[2 + indf];
					b     =  param[3 + indf];
					
					
					if(weaklearner == 0)
						
					{					
						
						sum    += (a*( z > th ) + b);	
						
					}			
					if(weaklearner == 1)
					{
						
						sum    += ((2.0/(1.0 + exp(-2.0*epsi*(a*z + b)))) - 1.0);
						
					}
					
					if(weaklearner == 2)
					{
						
						sum    += a*sign(z - th);
						
					}
					
					
					indf      += 4;
					
				}
				
				sum_total     += sum;
				
				if((sum_total < thresc) && (cascade_type == 1))
					
				{
					
					break;
					
				}

				else if(sum < thresc)
					
				{
					
					break;
					
				}
				
				indc      += 2; 
			}
			
			
			if(cascade_type )
				
			{
				
				fx[v]     = sum_total;
				
			}
			else
			{
					
				fx[v]     = sum;
				
			}
			
			indNyNx  += NyNx;
			
		}
			
	}
	
	mxFree(II);
	mxFree(Itemp);
	
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

/*----------------------------------------------------------------------------------------------------------------------------------------------*/

void MakeIntegralImage(unsigned char *pIn, unsigned int *pOut, int iXmax, int iYmax , unsigned int *pTemp)

{
	/* Variable declaration */
	int x , y , indx;
	
	indx                = 0;
	
	for(x=0 ; x<iXmax ; x++)
	{
		pTemp[indx]     = (unsigned int) pIn[indx];
	
		indx           += iYmax;
	}
	
	for(y = 1 ; y<iYmax ; y++)
	{
		pTemp[y]        = pTemp[y - 1] + (unsigned int)pIn[y];

	}
	
	pOut[0]             = (unsigned int) pIn[0];

	indx                = iYmax;

	for(x=1 ; x<iXmax ; x++)
	{
		pOut[indx]      = pOut[indx - iYmax] + pTemp[indx];

		indx           += iYmax;
	}
	
	for(y = 1 ; y<iYmax ; y++)
	{

		pOut[y]         = pOut[y - 1] + (unsigned int) pIn[y];

	}
	
	/* Calculate integral image */

	indx                = iYmax;

	for(x = 1 ; x < iXmax ; x++)
	{
		for(y = 1 ; y < iYmax ; y++)
		{

			pTemp[y + indx]    = pTemp[y - 1 + indx] + (unsigned int) pIn[y + indx];
			
			pOut[y + indx]     = pOut[y + indx - iYmax] + pTemp[y + indx];

		}

		indx += iYmax;
	}
}

/*----------------------------------------------------------------------------------------------------------------------------------------------*/


unsigned int Area(unsigned int *II , int x , int y , int w , int h , int Ny)
{
	
	int h1 = h-1, w1 = w-1 , x1 = x-1, y1 = y-1;
	
	
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

double haar_feat(unsigned int *II , int featidx , double *rect_param , unsigned int *F , int Ny , int nR , int nF)
{

	int x , xr , y , yr , w , wr , h , hr , r ,  R , indR , indF = featidx*6;

	int coeffw , coeffh;

	double val = 0.0 , s;

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

/*---------------------------------------------------------------------------------------------------------------------------------------------- */
