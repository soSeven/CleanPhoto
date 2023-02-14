//
//  DatePicker.swift
//  Clean
//
//  Created by liqi on 2020/11/5.
//

import UIKit

enum DatePickerComponent : Int
{
    case month, year
}

class DatePickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource
{
    private let bigRowCount = 1000
    private let componentsCount = 2
    var minYear = 2008
    var maxYear = 2031
    var rowHeight : CGFloat = 40.uiX
    
    var monthFont = UIFont(style: .regular, size: 15.uiX)
    var monthSelectedFont = UIFont(style: .regular, size: 15.uiX)
    
    var yearFont = UIFont(style: .regular, size: 15.uiX)
    var yearSelectedFont = UIFont(style: .regular, size: 15.uiX)

    var monthTextColor = UIColor(hex: "#333333")
    var monthSelectedTextColor = UIColor(hex: "#333333")
    
    var yearTextColor = UIColor(hex: "#333333")
    var yearSelectedTextColor = UIColor(hex: "#333333")
        
    private let formatter = DateFormatter.init()

    private var rowLabel : UILabel
    {
        let label = UILabel.init(frame: CGRect(x: 0, y: 0, width: componentWidth, height: rowHeight))
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        return label
    }

    var months : Array<String>
    {
        return ["一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月"]
    }
    
    var years : Array<String>
    {
        let years = [Int](minYear...maxYear)
        var names = [String]()
        for year in years
        {
            names.append(String(year))
        }
        return names
    }
    
    var currentMonthName : String
    {
        formatter.locale = Locale.init(identifier: "en_US")
        formatter.dateFormat = "MMMM"
        let dateString = formatter.string(from: Date.init())
        return NSLocalizedString(dateString, comment: "")
    }

    var currentYearName : String
    {
        formatter.locale = Locale.init(identifier: "en_US")
        formatter.dateFormat = "yyyy"
        return formatter.string(from: Date.init())
    }
    
    private var bigRowMonthCount : Int
    {
        return months.count  * bigRowCount
    }
 
    private var bigRowYearCount : Int
    {
        return years.count  * bigRowCount
    }
    
    private var componentWidth : CGFloat
    {
        return self.bounds.size.width / CGFloat(componentsCount)
    }
    
    private var todayIndexPath : IndexPath
    {
        var row = 0
        var section = 0
        let currentMonthName = self.currentMonthName
        let currentYearName = self.currentYearName

        for month in months
        {
            if month == currentMonthName
            {
                row = months.firstIndex(of: month)!
                row += bigRowMonthCount / 2
                break;
            }
        }
        
        for year in years
        {
            if year == currentYearName
            {
                section = years.firstIndex(of: year)!
                section += bigRowYearCount / 2
                break;
            }
        }
        return IndexPath.init(row: row, section: section)
    }
    
    var date : Date
    {
        let month = selectedRow(inComponent: DatePickerComponent.month.rawValue) % months.count + 1
        let year = years[selectedRow(inComponent: DatePickerComponent.year.rawValue) % years.count]
        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyy:MM"
        let str = String(format: "%@:%.2d", year, month)
        let date = formatter.date(from: str)
        return date!
    }
    
    var currentDate: (Int, Int) {
        let month = selectedRow(inComponent: DatePickerComponent.month.rawValue) % months.count + 1
        let year = years[selectedRow(inComponent: DatePickerComponent.year.rawValue) % years.count]
        return (year.int ?? 0, month)
    }
    
    //MARK: - Override

    override init(frame: CGRect)
    {
        super.init(frame: frame)
        loadDefaultsParameters()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        loadDefaultsParameters()
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        loadDefaultsParameters()
    }
    
    //MARK: - Open

    func selectToday()
    {
        selectRow((todayIndexPath as NSIndexPath).row, inComponent: DatePickerComponent.month.rawValue, animated: false)
        selectRow((todayIndexPath as NSIndexPath).section, inComponent: DatePickerComponent.year.rawValue, animated: false)
    }
    
    func selectCurrent(year: Int, month: Int)
    {
        let index = years.firstIndex(of: "\(year)") ?? 0
        selectRow(month - 1, inComponent: DatePickerComponent.month.rawValue, animated: false)
        selectRow(index, inComponent: DatePickerComponent.year.rawValue, animated: false)
    }
    
    //MARK: - UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat
    {
        return componentWidth
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        let label : UILabel
        if view is UILabel
        {
            label = view as! UILabel
        }
        else
        {
            label = rowLabel
        }
        
        let selected = isSelectedRow(row, component: component)
        label.font = selected ? selectedFontForComponent(component) : fontForComponent(component)
        label.textColor = selected ? selectedColorForComponent(component) : colorForComponent(component)
        label.text = titleForRow(row, component: component)
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat
    {
        return rowHeight
    }
    
    //MARK: - UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return componentsCount
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        if component == DatePickerComponent.month.rawValue
        {
            return bigRowMonthCount
        }
        return bigRowYearCount
    }
    
    //MARK: - Private
    
    private func loadDefaultsParameters()
    {
        delegate = self
        dataSource = self
    }
    
    private func isSelectedRow(_ row : Int, component : Int) -> Bool
    {
        var selected = false
        if component == DatePickerComponent.month.rawValue
        {
            let name = months[row % months.count]
            if name == currentMonthName
            {
                selected = true
            }
        }
        else
        {
            let name = years[row % years.count]
            if name == currentYearName
            {
                selected = true
            }
        }
        
        return selected
    }
    
    private func selectedColorForComponent(_ component : Int) -> UIColor
    {
        if component == DatePickerComponent.month.rawValue
        {
            return monthSelectedTextColor
        }
        return yearSelectedTextColor
    }
    
    private func colorForComponent(_ component : Int) -> UIColor
    {
        if component == DatePickerComponent.month.rawValue
        {
            return monthTextColor
        }
        return yearTextColor
    }
    
    private func selectedFontForComponent(_ component : Int) -> UIFont
    {
        if component == DatePickerComponent.month.rawValue
        {
            return monthSelectedFont
        }
        return yearSelectedFont
    }
    
    private func fontForComponent(_ component : Int) -> UIFont
    {
        if component == DatePickerComponent.month.rawValue
        {
            return monthFont
        }
        return yearFont
    }
    
    private func titleForRow(_ row : Int, component : Int) -> String
    {
        if component == DatePickerComponent.month.rawValue
        {
            return months[row % months.count]
        }
        return years[row % years.count]
    }
}
