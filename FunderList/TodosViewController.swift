//
//  TodosViewController.swift
//  FunderList
//
//  Created by Jay Lingelbach on 10/9/15.
//  Copyright © 2015 Jay Lingelbach. All rights reserved.
//

import UIKit
import CoreData

class TodosViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var baseArray: [[TodoModel]] = []
    
    var selectedTodoIndexPath: NSIndexPath!
    
    // instance variable for working with coredata and make it an optional
    var context: NSManagedObjectContext?
    
    // we need to create an instance variable for the fetched results controller and make it an optional
    var fetchedResultsController: NSFetchedResultsController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set dataSource and delegate to self
        tableView.dataSource = self
        tableView.delegate = self
        
        //tableview background color
        tableView.backgroundColor = UIColor.clearColor()
        
        // way to enter editing mode
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressRecognized:")
        
        gestureRecognizer.minimumPressDuration = 1.0
        gestureRecognizer.numberOfTouchesRequired = 1
        
        tableView.addGestureRecognizer(gestureRecognizer)
        
        //colon needed because passing a parameter in
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        let createNewItem: AddTodoTableViewCell = tableView.dequeueReusableCellWithIdentifier("AddTodoCell") as! AddTodoTableViewCell
        
        createNewItem.backgroundColor = UIColor(red: 208/255, green: 198/255, blue: 177/255, alpha: 0.7)
        createNewItem.favoriteButton.backgroundColor = UIColor.orangeColor()
        
        //setup tableView header
        tableView.tableHeaderView = UIView.init(frame: createNewItem.frame)
        // table header view must be initialized and added to our tableheader view
        tableView.tableHeaderView?.addSubview(createNewItem)
        
        
        
        // setup the NSFetchedResultsController with the context we previously set up
        
        if let context = context {
            // we need to specify the entity, in this case we only have one which is TodoModel
            let request = NSFetchRequest(entityName: "TodoModel")
            // we need to order our results somehow, so we're ordering them by due date at the moment
            let dateSort = NSSortDescriptor(key: "dueDate", ascending: true)
                        // new request based on section
            let sectionSort = NSSortDescriptor(key: "section", ascending: false)
            
            request.sortDescriptors = [sectionSort, dateSort]

            // configure the fetch request with  the request, the context and a cache
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "section", cacheName: "AllTodos")
            
            // we need to tell the fetchedResultsController who its delegate is, in this case, this instance of ViewController
            fetchedResultsController?.delegate = self
            
            // Finally we try to perform the fetch by using the `try` keyword because this is a throwing function
            do {
                try fetchedResultsController?.performFetch()
            } catch {
                print("There was a problem fetching.")
            }
        }
        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "todosToTodoSegue" {
            let indexPath = sender as! NSIndexPath
            let selectedTodo = fetchedResultsController?.objectAtIndexPath(indexPath) as? TodoModel
            
            // the segue has the view controller we are going to already mapped, but it doesn't know what type. use as!
            let todoViewController = segue.destinationViewController as! TodoViewController
            todoViewController.context = context
            todoViewController.todo = selectedTodo
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
            
        else if sender.title == "Done" {
            
            // This line is a bit different because we've added a header to our table
            let addTodoTableViewCell = tableView.tableHeaderView?.subviews.first as! AddTodoTableViewCell
            
            // add a new To Do object
            if addTodoTableViewCell.addTodoTextField.text != "" {
                
                // make sure we can get the Core Data context
                guard let context = context else { return }
                
                // create a todo object based on the Entity we created in the modeling tools
                guard let todo = NSEntityDescription.insertNewObjectForEntityForName("TodoModel", inManagedObjectContext: context) as? TodoModel else { return }
                
                // change the To Do's title to whatever the user inputs in the text field
                todo.title = addTodoTableViewCell.addTodoTextField.text!
                
                // reset the text field back to blank
                addTodoTableViewCell.addTodoTextField.text = ""
                
                // dismiss the keyboard
                addTodoTableViewCell.addTodoTextField.resignFirstResponder()
            }
                
                // if there is an error, alert the user, this stays just like before.
            else {
                let alert = UIAlertController(title: "Invalid Todo", message: "Please enter a title before adding a todo", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
}



// !!!!! ----- TODO tableView delegate extension ----- !!!!!

extension TodosViewController: TodoTableViewCellDelegate {
    
    func completeTodo(cell: TodoTableViewCell) {
        //We pass the whole cell, instead of the indexPath because we could get a potential out of range error with the indexPath when moving items from one section to another
        //repeatedly. This is because, since we have two different sections, the indexPath might change when an item moves to another section. Passing the whole cell solves this issue 
        //because the cell knows its own indexPath, regardless or what section it is in.
        
        
        // Now that we are passing the whole cell, we need to get the indexPath from it
        let indexPath = tableView.indexPathForCell(cell)
        print("Complete Todo at indexPath:", indexPath)
        // completed is no longer a boolean, we now change the section attribute of the item in Core Data
        guard let selectedTodo = fetchedResultsController?.objectAtIndexPath(indexPath!) as? TodoModel else { return }
        print("Section was", selectedTodo.section!)
        if selectedTodo.section == "pending" {
            selectedTodo.section = "completed"
        } else {
            selectedTodo.section = "pending"
        }
        print("Now the section is: ", selectedTodo.section!)
        
    }
    
    func favoriteTodo(cell: TodoTableViewCell) {
        print("Favorite Todo")
        
        let indexPath = tableView.indexPathForCell(cell)
        
        guard let selectedTodo = fetchedResultsController?.objectAtIndexPath(indexPath!) as? TodoModel else { return }
        
        if selectedTodo.favorited == 1 {
            selectedTodo.favorited = nil
        } else {
            selectedTodo.favorited = 1
        }
    }
}
// !!!!! ----- UITableView DELEGATE extension ----- !!!!!

extension TodosViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        performSegueWithIdentifier("todosToTodoSegue", sender: indexPath)
        selectedTodoIndexPath = indexPath
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
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
        return 25
    }
}


extension TodosViewController: UITableViewDataSource {
    
    // !!!!! ----- can edit row at indexPath ----- !!!!!
    // This fixes the bug where the input could be swiped to the left and deleted
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    // !!!!! ----- Title for header in section ----- !!!!!
    // This controls the space between sections
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            guard let sections = fetchedResultsController?.sections else { return "" }
            let currentSection = sections[section]
            return "\(currentSection.name.capitalizedString)"
    }
    
    
    // !!!!! ----- cell for row at indexpath ----- !!!!!
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: TodoTableViewCell = tableView.dequeueReusableCellWithIdentifier("TodoCell") as! TodoTableViewCell
        guard let currentTodo = fetchedResultsController?.objectAtIndexPath(indexPath) as? TodoModel else { return cell }        
        cell.titleLabel.text = currentTodo.title
        // date stuffs
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = currentTodo.dueDate {
            let dateString = dateStringFormatter.stringFromDate(date)
            cell.dateLabel.text = dateString
        }
        
        if currentTodo.section == "pending" {
            cell.completeButton.backgroundColor = UIColor.redColor()
        } else {
            cell.completeButton.backgroundColor = UIColor.greenColor()
        }
        
        if (currentTodo.favorited != nil) {
            cell.favoriteButton.backgroundColor = UIColor.blueColor()
        } else {
            cell.favoriteButton.backgroundColor = UIColor.orangeColor()
        }
        cell.backgroundColor = UIColor(red: 235/255, green: 176/255, blue: 53/255, alpha: 0.7)
        cell.indexPath = indexPath
        cell.delegate = self
        return cell
        
        
    }
    
    // !!!!! ----- number of sections in tableView ----- !!!!!
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    
    // !!!!! ----- number of rows in section ----- !!!!!
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let sections = fetchedResultsController?.sections else { return 0 }
        
        let currentSection = sections[section]
        
        return currentSection.numberOfObjects
        
    }
    
    // !!!!! ----- can move row at indexPath ----- !!!!!
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // !!!!! ----- move row at indexpath ----- !!!!!
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
        let currentTodo = baseArray[0][sourceIndexPath.row]
        baseArray[0].removeAtIndex(sourceIndexPath.row)
        baseArray[0].insert(currentTodo, atIndex: destinationIndexPath.row)
    }
    
    
    // NOTE: table updates and saves to Core Data are now handled by the NSFetchedResultsController delegate methods below

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if let object = fetchedResultsController?.objectAtIndexPath(indexPath) as? TodoModel, context = context {
            context.deleteObject(object)
            }
        }
    
    func longPressRecognized(gestureRecognizer: UILongPressGestureRecognizer) {
        if !tableView.editing {
            tableView.editing = true
        }
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
    //


extension TodosViewController: NSFetchedResultsControllerDelegate {
    // this method is called any time the controller's content will change
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default: break
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        do {
            try context?.save()
        } catch {
            print("There was an error saving a new item to core data")
        }
        tableView.endUpdates()
    }
}




