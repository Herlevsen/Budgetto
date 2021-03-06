//
//  ViewController.swift
//  Budgetto
//
//  Created by Jens Herlevsen on 04/04/2016.
//  Copyright © 2016 SJT. All rights reserved.
//

import UIKit

class OverviewViewController: UIViewController, ReloadView {
    
    @IBOutlet weak var averageUsedLabel: UILabel!
    @IBOutlet weak var disposableIncomeDay: UILabel!
    @IBOutlet weak var disposableIncomeWeek: UILabel!
    @IBOutlet weak var disposableIncomeMonth: UILabel!
    @IBOutlet weak var expensesLabel: UILabel!
    @IBOutlet weak var remainingLabel: UILabel!
    @IBOutlet weak var budgetMonthLabel: UILabel!
    @IBOutlet weak var incomeLabel: UILabel!
    var totalExpenses = 0.0
    var totalIncome = 0.0
    var selectedMonth = MonthViewController.selectedMonth
    let calendar = NSCalendar.currentCalendar()
    var finances = [Finance]() {
        didSet {
            print(finances.count)
            getTotalExpenses()
            getTotalIncome()
            setupLabels()
            financesBar.percentage = getStatsPercentage()
            financesBar.setNeedsDisplay()
        }
    }
    
    let dao = DAO.instance
    
    @IBOutlet weak var monthSelectionButton: MonthSelectionButton!
    
    @IBAction func didTabMonthSelectionButton(sender: AnyObject) {
        monthSelectionButton.showMonthPickerView(self)
    }
    @IBOutlet weak var financesBar: OverviewBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.setDefaultBackground()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        monthSelectionButton = appDelegate.monthSelectionButton
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        loadData()
    }
    
    func loadData() {
        selectedMonth = MonthViewController.selectedMonth
        
        if(selectedMonth != nil) {
            self.finances = dao.getAllFinancesInMonth(selectedMonth!)
        }
    }
    
    func reloadView() {
        loadData()
    }
    
    func getTotalExpenses() {
        totalExpenses = 0
        for finance in self.finances {
            if finance is Expense
            {
                totalExpenses += Double(finance.amount!)
            }
        }
    }
    
    func getTotalIncome() {
        totalIncome = 0
        for finance in self.finances {
            if finance is Income
            {
                totalIncome += Double(finance.amount!)
            }
        }
    }
    
    func getDailySpent() -> Int {

        let days = calendar.component(.Day, fromDate: NSDate())
        return Int(totalExpenses)/days
        
    }
    
    func getAmountToSpendDaily() -> Int {
        
        let pastDays = calendar.component(.Day, fromDate: NSDate())
        let days = calendar.rangeOfUnit(.Day, inUnit: .Month, forDate: selectedMonth!.date!)
        let remainingDays = days.length-pastDays
        
        return (Int(totalIncome-totalExpenses))/remainingDays
    }
    
    func getStatsPercentage() -> CGFloat {
        let percentage = totalExpenses/totalIncome
        return percentage.isNaN ? CGFloat(0) : CGFloat(totalExpenses/totalIncome)
    }
    
    func setupLabels() {
        
        // top labels
        expensesLabel.text = "\(Int(totalExpenses)) kr."
        let remainingAmount = Int(totalIncome-totalExpenses)
        remainingAmount > 0 ? (remainingLabel.text = "+ \(remainingAmount) kr.") : (remainingLabel.text = " \(remainingAmount) kr.")
        incomeLabel.text = "\(Int(totalIncome)) kr."
        budgetMonthLabel.text = "Budget for \((selectedMonth!.date?.month())!)"
        
        // disposable labels
        disposableIncomeMonth.text = "\(Int(totalIncome-totalExpenses)) kr."
        disposableIncomeWeek.text = "\(getAmountToSpendDaily()*7) kr."
        disposableIncomeDay.text = "\(getAmountToSpendDaily()) kr."
        
        // average label
        averageUsedLabel.text = "Du har i gennemsnit brugt \(getDailySpent()) kroner hver dag denne måned."
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

