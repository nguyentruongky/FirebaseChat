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

[Ep5](https://www.youtube.com/watch?v=b1vrjt7Nvb0&list=PL0dzCUj1L5JEfHqwjBV0XFb9qx9cGXwkq&index=5): Upload user images to Firebase Storage. 

The UIImagePickerController returns some types of images, remember 2 of them: `UIImagePickerControllerEditedImage` and `UIImagePickerControllerOriginalImage`

	if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
        selectedImage = editedImage
    }
    else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage  {
        selectedImage = originalImage
    }

Something Brian didn't mention to, I found it when I worked. 

- Permission to access photo gallery: You will have a crash with no reason, maybe it happens only in Swift 3. Let's add some lines into `Info.plist` file. 

		<key>NSPhotoLibraryUsageDescription</key>
		<string>This app requires access to the photo library.</string>
		<key>NSCameraUsageDescription</key>
		<string>This app requires access to the camera.</string>

- Permission to upload photo to Firebase: By default, Firebase doesn't allow to access to Storage or Database without authentication. You can change that in `Storage\Rule` or `Database\Rule`. It's useful when your app doesn't require register or login. 

Change this 

	allow read, write: if request.auth != null; 
	
to this 

	allow read, write: if request.auth == null;

I did some difference with Brian. Move the upload code to a function with a callback instead of upload inside the handler function. 

	uploadProfileImage(name: fileName, completionHandler: { (metadata) in
		// prepare data to save into databse
		// save data to databse 
	}

I use the Firebase user uid instead of generate new one to store to storage. 

	let fileName = uid + ".png"

[Ep6](https://www.youtube.com/watch?v=GX4mcOOUrWQ&list=PL0dzCUj1L5JEfHqwjBV0XFb9qx9cGXwkq&index=6): Load images from Firebase and caching. The image from Firebase Storage has a url, stored to Firebase database. It's easy to download with 3rd lib such as Kingfisher or SDWebImage. They automatically cache the images. In this tutorial, Brian used URLSession to download and cache image manually. 

I learnt this in his building Youtube serial. So that I move code to my own cache class. Check it out at `ImageCaching.swift` file. Easily use with 

	avatarCaching.getImage(with: urlString) { (downloadedImage) in
		// update your image view
    }

[Ep7](https://www.youtube.com/watch?v=69LooiLYjQo&list=PL0dzCUj1L5JEfHqwjBV0XFb9qx9cGXwkq&index=7): Use `UIImageJPEGRepresentation` instead of `UIImagePNGRepresentation` to reduce the image quality to upload and download faster. 

	let uploadData = UIImageJPEGRepresentation(image, 0.1)

Update the title bar with user profile image and name. I did differently with Brian, created a protocol and pass data from `LoginController` to `MessageController` instead of pass `MessageController` instance. 

[Ep8](https://www.youtube.com/watch?v=FDay6ocBlnE): Create chat log controller to show the conversation. Save messages to Firebase database at node `childByAutoId`

	let ref = FIRDatabase.database().reference().child("messages")
	let childRef = ref.childByAutoId()
	let values = ["text": inputTextField.text!]
	childRef.updateChildValues(values)
	
[Ep9](https://www.youtube.com/watch?v=cw0gLZHJOiE): Get all messages from database and show in the tableView. Shouldn't use Xcode autocorrect to finish Firebase function. It's better type closures yourself.
	
	let ref = FIRDatabase.database().reference().child("messages")
	ref.observe(.childAdded, with: { snapshot in
		// parse messages data and render to UI
	})

[Ep10](https://www.youtube.com/watch?v=fyqksNlC8ks): Easy way to group the message as user. Add all messages into a dictionary as the value with the user id is the key. 

	self.messagesDictionary[toId] = message

Convert time interval (double value) to Date and format date to string

	let timestamp = Date(timeIntervalSince1970: seconds)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "hh:mm:ss a"
    timeLabel.text = dateFormatter.string(from: timestamp)

[Ep11](https://www.youtube.com/watch?v=K1AgGLoT54M&list=PL0dzCUj1L5JEfHqwjBV0XFb9qx9cGXwkq&index=11&t=863s): create user_messages to to separate others user messages. From there, we can retrieve the messages content for the conversations. 

[Ep12](https://www.youtube.com/watch?v=azFjJZxZP6M&t=2s&index=12&list=PL0dzCUj1L5JEfHqwjBV0XFb9qx9cGXwkq#t=1679.170654): Load the user chat to the chat log controller. Filter the user message related to the current user and the selected user. 

[Ep13](https://www.youtube.com/watch?v=yhGw5bR46AQ&list=PL0dzCUj1L5JEfHqwjBV0XFb9qx9cGXwkq&index=13): Calculate the text size to make the collection view cell fit to the text. 

	 private func estimateFrameForText(text: String) -> CGRect {
	    let size = CGSize(width: 200, height: 100)
	    let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
	    return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 15)], context: nil)
	}

Should add some pixels for height padding 

	height = estimateFrameForText(text: text).height + 20

*Update later*