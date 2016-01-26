//
//  TodosViewController.swift
//  FunderList
//
//  Created by Jay Lingelbach on 10/9/15.
//  Copyright © 2015 Jay Lingelbach. All rights reserved.
//

import UIKit

class TodosViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var baseArray: [[TodoModel]] = []
    
    var selectedTodoIndexPath: NSIndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let todo1 = TodoModel(title: "Study iOS", favorited: false, dueDate: NSDate(), completed: false, repeated: nil, reminder: nil)
        let todo2 = TodoModel(title: "Eat dinner", favorited: false, dueDate: NSDate(), completed: false, repeated: nil, reminder: nil)
        let todo3 = TodoModel(title: "Gym", favorited: false, dueDate: NSDate(), completed: false, repeated: nil, reminder: nil)
        
        // holds todos and completed todos
        baseArray = [[todo1, todo2, todo3], []]
        
        // set dataSource and delegate to self
        tableView.dataSource = self
        tableView.delegate = self
        
        //tableview background color
        tableView.backgroundColor = UIColor.clearColor()
        
        
        
        // footer for tableView
        // to create need an instance of a UIView - because footer view is initially set as nil!
        // means we have to setup below in the UITableView Delegate extension
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        //colon needed because passing a parameter in
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        // ways to enter editing mode
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressRecognized:")
        
        gestureRecognizer.minimumPressDuration = 1.0
        gestureRecognizer.numberOfTouchesRequired = 1
        
        tableView.addGestureRecognizer(gestureRecognizer)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "todosToTodoSegue" {
            let indexPath = sender as! NSIndexPath
            //figure out which has been tapped
            let selectedTodo = baseArray[indexPath.section - 1][indexPath.row]
            
            // the segue has the view controller we are going to already mapped, but it doesn't know what type. use as!
            let todoViewController = segue.destinationViewController as! TodoViewController
            
            todoViewController.todo = selectedTodo
            todoViewController.mainVC = self
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    @IBAction func editBarButtonItemTapped(sender: UIBarButtonItem) {
        
        if sender.title == "Edit" {
            if tableView.editing {
                tableView.setEditing(false, animated: true)
            }
            else {
                tableView.setEditing(true, animated: true)
            }
        }
    
        // NEW CODE STARTS HERE
        else if sender.title == "Done" {
            let indexPathOfAddTodoCell = NSIndexPath(forRow: 0, inSection: 0)
            
            let addTodoTableViewCell = tableView.cellForRowAtIndexPath(indexPathOfAddTodoCell) as! AddTodoTableViewCell
            
            // "" because textfield doesn't return nil if empty. It returns an empty string.
            if addTodoTableViewCell.addTodoTextField.text != "" {
                
                let newTodo = TodoModel(title: addTodoTableViewCell.addTodoTextField.text!, favorited: addTodoTableViewCell.favorited, dueDate: nil, completed: false, repeated: nil, reminder: nil)
                
                // add to base array
                baseArray[0].append(newTodo)
                
                tableView.reloadData()
                
                // reset to an empty string
                addTodoTableViewCell.addTodoTextField.text = ""
                //make the keyboard disappear
                addTodoTableViewCell.addTodoTextField.resignFirstResponder()
                
            }
                
            else {
                
                let alert = UIAlertController(title: "Invalid Todo", message: "Please enter a title before adding a todo", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                presentViewController(alert, animated: true, completion: nil)
            }
            
        }
    }
    
}

    // !!!!! ----- TODO tableView delegate extension ----- !!!!!

extension TodosViewController: TodoTableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section != 0 {
            performSegueWithIdentifier("todosToTodoSegue", sender: indexPath)
           selectedTodoIndexPath = indexPath
            
            tableView.deselectRowAtIndexPath(indexPath, animated: false)

        }
        
    }
    
    func completeTodo(indexPath: NSIndexPath) {
        print("complete todo")
        
        var selectedTodo = baseArray[indexPath.section - 1][indexPath.row]
        selectedTodo.completed = !selectedTodo.completed
        
        if indexPath.section == 1 {
            baseArray[1].append(selectedTodo)
        }
        else {
            baseArray[0].append(selectedTodo)
        }
        
        baseArray[indexPath.section - 1].removeAtIndex(indexPath.row)
        tableView.reloadData()
    }
    
    func favoriteTodo(indexPath: NSIndexPath) {
        print("Favorite todo")
    }
    
}
    // !!!!! ----- UITableView DELEGATE extension ----- !!!!!

extension TodosViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section != 0 {
            performSegueWithIdentifier("todosToTodoSegue", sender: indexPath)
            
            selectedTodoIndexPath = indexPath

            tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
    }
    
    // remove delete buttons while in editing mode
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if tableView.editing {
            return .None
        }
        return .Delete
    }
    
    // remove indent for rows when in editing mode (no longer a delete button)
    
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    // These two are needed for implementation of the footers. Before this is added need to set an UIView instance as done above: tableView.tableFooterView = UIView(frame: CGRectZero)
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    // !!!!! ----- will display cell ----- !!!!!
    // lines in the tableView now go all the way to the edge instead of having an inset
    // This is the place to do cell modifications!!!!!
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    
    // !!!!! ----- height for header in section ----- !!!!!
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 && baseArray[1].count > 0 {
            //header height
            return 25
        }
        return 0
    }
    
   
}


extension TodosViewController: UITableViewDataSource {
    
    // !!!!! ----- can edit row at indexPath ----- !!!!!
    // This fixes the bug where the input could be swiped to the left and deleted

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        }
        
        return true
    }
    
    
    // !!!!! ----- Title for header in section ----- !!!!!
    // This controls the space between sections
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 2 && baseArray[0].count > 0 {
            return "\(baseArray[1].count) Completed Items"
        }
        
        return ""
    }
    
    // !!!!! ----- cell for row at indexpath ----- !!!!!
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell: AddTodoTableViewCell = tableView.dequeueReusableCellWithIdentifier("AddTodoCell") as! AddTodoTableViewCell
            cell.backgroundColor = UIColor(red: 208/55, green: 198/255, blue: 177/255, alpha: 0.7)
            
            cell.favoriteButton.backgroundColor = UIColor.orangeColor()

            
            return cell
        }
            
        else if indexPath.section == 1 || indexPath.section == 2 {
            
            let currentTodo = baseArray[indexPath.section - 1][indexPath.row]
            let cell: TodoTableViewCell = tableView.dequeueReusableCellWithIdentifier("TodoCell") as! TodoTableViewCell
            
            cell.titleLabel.text = currentTodo.title
            // date stuffs
            let dateStringFormatter = NSDateFormatter()
            dateStringFormatter.dateFormat = "yyyy-MM-dd"
            
            if let date = currentTodo.dueDate {
                let dateString = dateStringFormatter.stringFromDate(date)
                cell.dateLabel.text = dateString
            }
            
            if indexPath.section == 1 {
                
                cell.completeButton.backgroundColor = UIColor.redColor()
            }
                
            else {
                
                cell.completeButton.backgroundColor = UIColor.greenColor()
            }
            
            if currentTodo.favorited {
                
                cell.favoriteButton.backgroundColor = UIColor.blueColor()
                
            }
                
            else {
                cell.favoriteButton.backgroundColor = UIColor.orangeColor()
            }
            
            cell.backgroundColor = UIColor(red: 235/255, green: 176/255, blue: 53/255, alpha: 0.7)
            
            cell.indexPath = indexPath
            cell.delegate = self
            
            
            return cell
        }
            
        else {
            return UITableViewCell()
        }
    }
    
    // !!!!! ----- number of sections in tableView ----- !!!!!

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    
    // !!!!! ----- number of rows in section ----- !!!!!

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        }
            
        else if section == 1 {
            return baseArray[0].count
        }
            
        else if section == 2 {
            return baseArray[1].count
        }
            
        else {
            return 0
        }
    }
    
    // !!!!! ----- can move row at indexPath ----- !!!!!

    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 1 {
            return true
        }
        else {
            return false
        }
    }
    
    // !!!!! ----- move row at indexpath ----- !!!!!

    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
       let currentTodo = baseArray[0][sourceIndexPath.row]
        baseArray[0].removeAtIndex(sourceIndexPath.row)
        baseArray[0].insert(currentTodo, atIndex: destinationIndexPath.row)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            tableView.beginUpdates()
            // select what to get rid of
            baseArray[indexPath.section - 1].removeAtIndex(indexPath.row)
            
            // later tater!
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
            // end updates
            tableView.endUpdates()
        }
    }
    
    func longPressRecognized(gestureRecognizer: UILongPressGestureRecognizer) {
        if !tableView.editing {
            tableView.editing = true
        }
    }
    
    //: MARK - KEYBOARD NOTIFICATIONS
    
    
    // !!!!! ----- keyboard will show function ----- !!!!!
    
    func keyboardWillShow(notification: NSNotification) {
        navigationItem.rightBarButtonItem?.title = "Done"
    }
    
    // !!!!! ----- keyboard will hide function ----- !!!!!
    
    func keyboardWillHide (notification: NSNotification) {
        navigationItem.rightBarButtonItem?.title = "Edit"
    }
}






