# FirebaseChat
This project follows the tutorial at [Lets build that app](https://www.youtube.com/channel/UCuP2vJ6kRutQBfRmdcI92mA) of Brain Voong. Build an chat app with the Firebase 3 backend. It's a really useful tutorial for experienced iOS developers. 

In the tutorial, Brian used Swift 2.3, I started this on October, so that I used Swift 3. 

The greatest thing I learnt from Brian is he just uses Auto layout programmatically. Incredible. 

[Ep1](https://www.youtube.com/watch?v=lWSc0wHFTXM&list=PL0dzCUj1L5JEfHqwjBV0XFb9qx9cGXwkq&index=1):  Build the login controller with Constraint Anchors. You can take a lot at my Youtube clone (followed another tutorial) to see my notes. There are some useful note here. Something is extend UIColor init, start app programmatically. 

[Ep2](https://www.youtube.com/watch?v=guFW9aj4EHM&index=2&list=PL0dzCUj1L5JEfHqwjBV0XFb9qx9cGXwkq): Create app in Firebase console. Connect the project with the Firebase via SDK installed by Cocodpod. First data added to Firebase databse.

Create registered user to Firebase Authentication. 

	FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
		// do your job here. 
	}
	
Save user information to Firebase Database. Firebase Database is a NoSQL, it uses node instead of table. 

	let ref = FIRDatabase.database().reference(fromURL: "https://your_app_url.firebaseio.com/")
    let node = ref.child("fatherItem").child("littleChildItem")
    let dataToSave = [
        "key": value,
    ]
    node.updateChildValues(values, withCompletionBlock: { (error, ref) in
		// do your job here
    })
    
[Ep3](https://www.youtube.com/watch?v=4rNtIeC_dsQ&index=3&list=PL0dzCUj1L5JEfHqwjBV0XFb9qx9cGXwkq): Handle login function. Change the UI to toggle login and register. Login to the registered account with Firebase. 

	FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in 
		// do your job here
	}

[Ep4](https://www.youtube.com/watch?v=qD582zfXlgo&list=PL0dzCUj1L5JEfHqwjBV0XFb9qx9cGXwkq&index=4): Fetch all users from Firebase. 

The observe type .childAdded will create a connection to Firebase and be called every time new user registered. 

	FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in

		// your job goes here 
	}

*Update later*