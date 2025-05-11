
bspace = 31/2; // bolt spacing
ybase = 42.5;
xbase = 42.5;
holerad = 1.75;

shuttlelength = 50;
shuttlewidth  = 80 ;
tubelength = 100;

v608innerdiam = 6;

pi=3.1415926535897932384626433832795;
innerRadius=3.1;//shaft radius, in mm
borders=2.5;//how thick should the borders around the central "shaft" be, in mm
diametralPitch=12;
numberOfTeeth=19;
pressureAngle=20*pi/180;
centerAngle=25;//angle at center of teeth

divs = 30; // how round to make all the circles

div = divs; // how round to make all the circles


module rack(innerRadius,borders,P,N,PA,CA)
{
	// P = diametral pitch
	// N = number of teeth
	// PA = pressure angle in radians
	// x, y = linear offset distances
	a = 1/P; // addendum (also known as "module")
	d = 1.25/P; // dedendum (this is set by a standard)
	multiplier=20;//20
	height=(d+a)*multiplier;
	
	
	// find the tangent of pressure angle once
	tanPA = tan(PA*(180/pi));
	// length of bottom and top horizontal segments of tooth profile
	botL = (pi/P/2 - 2*d*tanPA)*multiplier;
	topL =( pi/P/2 - 2*a*tanPA)*multiplier;

	slantLng=tanPA*height;
	realBase=2*slantLng+topL;
	
	
	offset=topL+botL+2*slantLng;
	length=(realBase+botL)*N;

	supportSize=(innerRadius+borders)*2;

	//calculate tooth params
	basesegmentL=realBase/2;
	basesegmentW=supportSize/2;

	topsegmentL=topL/2;
	topsegmentW=supportSize/2;

	baseoffsetY=tan(CA)*basesegmentW;
	topoffsetY=tan(CA)*topsegmentW;
	
	//calculate support params

	totalSupportLength=(N)*(offset);
	supportL=totalSupportLength/2;
	supportW=supportSize/1.99;
	
	echo("Total length",totalSupportLength+baseoffsetY);
	echo("Total height",supportSize);

	
	rotate([90,90,0])
	{
	translate([-supportSize/2,supportSize/2,0])
	{
	union()
	{
		translate(v=[0,0,3.8])
			support(supportL,supportW,supportSize/3,baseoffsetY);
	
		for (i = [0:N-1]) 
		{
			translate([0,i*offset-length/2+realBase/2,supportSize/2+height/2]) 
			{	
				
				tooth(basesegmentL,basesegmentW,topsegmentL,topsegmentW,height,baseoffsetY,topoffsetY);
				
			}
		}
	}
	
	}
	}
}

module support(supportL,supportW,height,offsetY)
{
	 tooth(supportL,supportW,supportL,supportW,height,offsetY,offsetY);
}

module myrack()
{
	difference()
	{
	union()
	{
		rotate(a=[-90,0,90])
			rack(innerRadius,borders,diametralPitch,numberOfTeeth,pressureAngle,centerAngle);

		translate(v = [-12.4,3,5.55])
			cube([2.5,99.25,7.5],center = true);

		translate(v = [1.25,3,5.55])
			cube([2.5,99.25,7.5],center = true);
	}
	translate(v = [-15,0,-3])
		cube([40,120,10],center = true);
	}

}

module tooth(basesegmentL,basesegmentW,topsegmentL,topsegmentW,height,baseoffsetY,topoffsetY)//top : width*length, same for base
{
	
	////////////////
	basePT1=[ 	-basesegmentW, 	basesegmentL-baseoffsetY, 	-height/2];
	basePT2=[	0, 	basesegmentL, 	-height/2];
	basePT3=[ 	basesegmentW, 	basesegmentL-baseoffsetY, 	-height/2];
	basePT4=[ 	basesegmentW, 	basesegmentL-(baseoffsetY+basesegmentL*2), 	-height/2];	
	basePT5=[ 	0,	-basesegmentL,	-height/2];
	basePT6=[	-basesegmentW,	basesegmentL-(baseoffsetY+basesegmentL*2),	-height/2];
	//////////////////////////
	topPT1=[	-topsegmentW,	topsegmentL-topoffsetY,	height/2];
	topPT2=[	0,	topsegmentL,	height/2];
	topPT3=[	topsegmentW,	topsegmentL-topoffsetY,	height/2];
	topPT4=[	topsegmentW,	topsegmentL-(topoffsetY+topsegmentL*2),	height/2];	
	topPT5=[	0,	-topsegmentL,	height/2];
	topPT6=[	-topsegmentW,	topsegmentL-(topoffsetY+topsegmentL*2),	height/2];
	//////////////////////////

	//////////////////////////

	polyhedron(
	points=[basePT1,basePT2,basePT3,	basePT4,basePT5,basePT6,
		topPT1,topPT2,topPT3,topPT4,topPT5,topPT6],
		triangles=[	[5,1,0],	[4,1,5],	[4,2,1],	[3,2,4],	
		[1,6,0],	[7,6,1],	[2,7,1],	[8,7,2],
		[11,10,5],	[5,10,4],	[10,9,4],	[4,9,3],	
		[0,11,5],	[6,11,0],	
		[3,8,2],	[9,8,3],	
		[9,10,8],	[10,7,8],	[11,7,10],	[6,7,11],	]
	);
}


// this module makes the mounting hole for the Nema 1.7 motor
module steppermount(cx,cy,cz,rad)
{
		//make a hole for the stepper
         		 translate(v=[cx,cy,cz])
          	{
	       		 cylinder(h = 30, r=11.5,$fn =div); // 22mm radius for center on motor
		}
		//bolts are 31 mm spaced from each other

         		 translate(v=[cx+bspace,cy+bspace,cz])
          	{
	       		 cylinder(h = 30, r=rad,$fn =div);
	       		 cylinder(h = 3, r=3,$fn =div);
		}	
         		 translate(v=[cx+bspace,cy-bspace,cz])
          	{
	       		 cylinder(h = 30, r=rad,$fn =div);
	       		 cylinder(h = 3, r=3,$fn =div);
		}	
         		 translate(v=[cx-bspace,cy+bspace,cz])
          	{
	       		 cylinder(h = 30, r=rad,$fn =div);
	       		 cylinder(h = 3, r=3,$fn =div);
		}	
         		 translate(v=[cx-bspace,cy-bspace,cz])
          	{
	       		 cylinder(h = 30, r=rad,$fn =div);
	       		 cylinder(h = 3, r=3,$fn =div);
		}	
}

//simple connector for joining tubes together
module tubeconnector()
{
	cube([16,50,12],center = true);
}
tuberad = 5;
module tube4()
{
		difference()
		{
			union()
			{
				cube([30,tubelength,20],center = true);

				translate(v=[0,0,-10])
				{
					cube([20,tubelength,10],center = true);
				}

				translate(v=[0,0,-27.5 + 10])
				{
					cube([40,tubelength,5],center = true);					
				}
			}

			//make it a tube - hollow center
			translate(v=[0,0,-8])
			{
				cube([12,tubelength,16],center = true);
			}
			//right rail
			translate(v=[15,0,0])
			{
				cube([6,tubelength,8],center = true);
			}

			//left rail
			translate(v=[-15,0,0])
			{
				cube([6,tubelength,8],center = true);
			}

			//top rail for myrack
			translate(v=[0,0,6.5])
			{
				cube([16,tubelength,7],center = true);
			}
/*
			//mounting holes
			for(n=[1:5])
			{
				translate(v=[15,-60 + n*20,-22])
					cylinder(h=10,r=(5/2),$fn=10);

				translate(v=[-15,-60 + n*20,-22])
					cylinder(h=10,r=(5/2),$fn=10);
			}
*/
		}

}

shuttlethickness = 12; // 12 mm
lowershuttlethickness = 7; // 7mm is the height of the 5/16 nut
innerridediam  = 10; // 10mm is the 608 bearing inner ride diameter
riserheight = 2; // height of the riser the bearing rests on

// this is the bottom block portion of the lower shuttle assembly

LowerShuttleBottomthickness = 5;

module LowerShuttleBottom()
{
	difference()
	{
		union()
		{
			cube(size = [12,40,LowerShuttleBottomthickness],center = true);

			translate(v=[0,15,(LowerShuttleBottomthickness)/2])
				cylinder(h = riserheight, r = innerridediam/2 );

			translate(v=[0,-15,(LowerShuttleBottomthickness)/2])
				cylinder(h = riserheight, r = innerridediam/2 );
		}
		
		translate(v=[0,15,-7.5])
			cylinder(h = 15, r = 8/2 ); // this is the portion the 608 plugs into
		translate(v=[0,-15,-7.5])
			cylinder(h = 15, r = 8/2 );
		
	}
}

module LowerShuttle()
{
	difference()
	{
	union()
	{	
			cube(size = [12,40,shuttlethickness + lowershuttlethickness],center = true);

			translate(v=[0,15,(shuttlethickness + lowershuttlethickness)/2])
				cylinder(h = riserheight, r = innerridediam/2 );

			translate(v=[0,-15,(shuttlethickness + lowershuttlethickness)/2])
				cylinder(h = riserheight, r = innerridediam/2 );

			translate(v=[0,15,(shuttlethickness + lowershuttlethickness + riserheight)/2])
				cylinder(h = 15, r = 8/2 ); // this is the portion the 608 plugs into
			translate(v=[0,-15,(shuttlethickness + lowershuttlethickness + riserheight)/2])
				cylinder(h = 15, r = 8/2 );
		}
		translate(v=[0,25,-5])
			rotate(a=[90,0,0])
				cylinder(h=50,r=3/2,$fn=20);
	
	}
}

module LowerAssembly()
{
	LowerShuttle();

	translate(v=[0,0,22.5])
	rotate(a=[180,0,0])
		LowerShuttleBottom();

}

motormountthickness = 5.5;
module Shuttle2()
{
	difference()
	{
		union(){
			//start with a flat base
			translate(v = [-2.5,0,3]) //2mm above surface
				cube(size = [70,50,shuttlethickness],center = true);

			//bearing pillow block
			translate(v = [-11.5,30,11.5]) 
				cube(size = [10,25,25+4],center = true);

			//bearing pillow block
			translate(v = [10.5,30,11.5]) 
				cube(size = [10,25,25+4],center = true);

			// motor block mount 
			translate(v = [8.25,0,30]) 
				cube(size = [motormountthickness,50,42],center = true);
		}	

		//general purpose mounting holes
			translate(v = [-20,15,-5]) 
				cylinder(h=20,r=5/2,$fn=20);
			translate(v = [-20,-15,-5]) 
				cylinder(h=20,r=5/2,$fn=20);
			translate(v = [-30,15,-5]) 
				cylinder(h=20,r=5/2,$fn=20);
			translate(v = [-30,-15,-5]) 
				cylinder(h=20,r=5/2,$fn=20); 

		//remove the edge of the pillow block a bit..
		translate(v = [26,11,24]) 
			cube(size = [30,30,30],center = true);
			


		//take out the rod to lock the lower shuttle assembly in place
		translate(v=[23.5,-30,4.5])
			rotate(a=[-90,0,0])
				cylinder(h = 100,r = 3.1/2,$fn=21);


		//make a hole for the lowerassembly
			translate(v = [23.5,0,0])
				rotate(a=[0,180,0])
					cube(size=[12,40,20],center = true);//


		//holes on top of the pillow blocks for pressure screws
		translate(v = [-12,32,15])
				cylinder(h = 20,r = 3/2,$fn=10);
		translate(v = [10.25,32,15])
				cylinder(h = 20,r = 3/2,$fn=10);

		//make a mount for the stepper
		for(n=[0:5])
			translate(v=[30,n,30])
				rotate(a=[0,-90,0])
					steppermount(0,0,0,1.5);

		//take out space for shaft of large drive gear
		for(n=[1:5])
		{
			translate(v=[-18,32,18-n])
				rotate(a=[0,90,0])
					cylinder(h=34,r=8/2); //shaft size for 608 bearing
		}

		//take out the spot for the gear
		translate(v = [-.5,25,3]) //2mm above surface
			cube(size = [12,38,12],center = true);

	//right bolt
		for(n=[1:5]) //sliding mount hole	
		{
			translate(v = [-20 -n,0,-23.5])
				boltassembly();
			translate(v = [-20 -n,0,2])
				nut();
		}	
		//take out the nut to tighten
		translate(v=[-33.5,0,6])
			rotate(a=[0,90,0])
				smallnut();
		translate(v = [-38,0,6])
			rotate(a=[0,90,0])
				cylinder(h = 10,r = 3.1/2,$fn=10);

	}

//	fakestuff();
}


//motor, gears and fake bolts used for layout purposes
module fakestuff()
{
	translate(v=[30,0,30])
	{
		rotate(a=[0,-90,0])
			NEMA17();

		translate(v=[-35,0,0])
			rotate(a=[0,90,0])
				fakegear();		

		translate(v=[-35,32,-14])
			rotate(a=[0,90,0])
				fakebiggear();
	}

//left bolts
	translate(v = [23.5,-15,-23.5])
		boltassembly();

	translate(v = [23.5,15,-23.5])
		boltassembly();
//right bolt
	translate(v = [-23.5,0,-23.5])
		boltassembly();
	
}

// the big gear of the drive train, (sizing purposes only)
module fakegear()
{
	translate(v = [0,0,0])
		cylinder(r=25/2,h = 9);

}

// I think I'm going to move the bearing to the center of the big helical gear
module fakesmallbearing()
{
	difference()
	{
		cylinder(h=6,r=17.1/2);
		cylinder(h=6,r=6/3);
	}
}

// the big gear of the drive train, (sizing purposes only)
module fakebiggear()
{
	difference()
	{
		cylinder(r=46/2,h = 9);
		cylinder(r=6/2,h = 9);
	}

}

// this module contains a bolt with a bearing and a nut on it for 
// this module is for sizing purposes only
module boltassembly()
{
	union()
	{
		bolt();
		//fake the 608 bearing
		translate(v = [0,0,5])
			cylinder(r=11,h = 7);
		//add another nut
		translate(v = [0,0,12])
			cylinder(h = 7,r=7,$fn=6);
	}
}
// a rough approximation of a NEMA17 motor used for sizing purposes()
module NEMA17()
{
	union()
	{
		cube(size=[42,42,38],center = true);
		translate(v=[0,0,38/2])
			cylinder(h=2.5,r=11);
		translate(v=[0,0,38/2])
			cylinder(h=2.5,r=11);
		translate(v=[0,0,38/2])
			cylinder(h=13,r=2.5);
	}
}

module nut()
{
		cylinder(h=7,r=15/2,$fn=6);	
}
module smallnut()
{
	difference()
	{
		cylinder(h=2.5,r=7.5/2,$fn=6);
	}
		
}
module bolt(len = 30) // 5/16 or 8 mm bolt 30mm long with head
{
	union()
	{
		cylinder(h = len,r=4);
		cylinder(h = 5,r=7,$fn=6);
	}
}
/*
module LargeGear()
{
	//use<gears_helical_v2.scad>
	include<gears_helical_v2.scad>
	//big gear
	shaftDiam=13; //shaft diameter
	pitchDiam=42.5; //pitch diameter (45)
	teethNum=26; //number of teeth (int) (30)
	gearHeight=4.8; //gear depth
	doubleHelical=1; //int: 0=no, 1=yes (will make the gear 2x taller)
	toothWidth=2;
	difference()
	{
		union()
		{
			gear();
			cylinder(h=gearHeight*1,r=(pitchDiam/2)-2);
			
		}
		cylinder(h=gearHeight*2,r= shaftDiam/2);
		translate(v= [0,0,-2])
			cylinder(h=7,r=22.2/2);

	}	
}
*/
// this section turns on the visibility of sub-components 
// to make exporting as stl files easier

showtube = 1;
showshuttle = 1;
showlowershuttle = 1;
showrack = 1;
showbolts = 0;
showtubeconnector = 0;
//plate generation for multiple prints:
showtubeplate1 = 0;
showrackplate1 = 0;
showconnectorplate1 = 0;
showshuttleplate = 0;
importtest = 0;
//showlargegear = 0;

module main()
{
/*
	if(showlargegear == 1)
	{
		LargeGear();
	}
*/
	if(showshuttleplate==1)
	{
		translate(v=[-35,17,1])
			bolt(40);
		translate(v=[-3,-18,4])
			Shuttle2();

		translate(v=[-15,35,10.5])
			rotate(a=[0,0,90])
				LowerShuttle();

		translate(v=[37,-15,3.5])
			LowerShuttleBottom();

//		translate(v=[0,0,-0.5])
//			cube(size = [95,95,1],center = true);
		
	}
	if(showtubeconnector == 1)
	{
		tubeconnector();
	}
	if(showconnectorplate1 == 1)
	{
		tubeconnector();
	}

	if(showbolts == 1)
	{
		bolt(40);
	}
	if (showtubeplate1==1)
	{
		rotate(a=[0,-90,0])
			tube4();
		translate(v=[45,0,0])
			rotate(a=[0,90,0])
				tube4();	
/*
		translate(v=[0,0,45])
		rotate(a=[0,-90,0])
			tube4();
		translate(v=[45,0,45])
			rotate(a=[0,90,0])
				tube4();	
*/
	}

	if(showtube ==1)
	{
		tube4();
	}	
	if(showrack ==1)
	{
		translate(v =[5.5,0,0.5] )
		myrack();
	}	
	if(showrackplate1 ==1)
	{
		translate(v =[5.5,0,0.5] )
			myrack();
		translate(v =[5.5+20,0,0.5] )
			myrack();
		translate(v =[5.5+40,0,0.5] )
			myrack();
	}	
	if(showshuttle == 1)
	{
		translate(v=[0,0,15])
			Shuttle2();
	}
	if(showlowershuttle == 1)
	{
		translate(v=[23.5,0,14.5])
		rotate(a=[0,180,0])
			LowerAssembly();
	}
}

main();
