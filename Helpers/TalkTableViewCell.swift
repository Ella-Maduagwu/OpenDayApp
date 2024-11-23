import UIKit

class TalkTableViewCell: UITableViewCell {

    // Labels
    let titleLabel = UILabel()
    let timeLabel = UILabel()
    let venueLabel = UILabel()
    
    // Stack Views
    let mainStackView = UIStackView()
    let bottomStackView = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }

    private func setupCell() {
        // Configure Main Stack View
        mainStackView.axis = .vertical
        mainStackView.distribution = .fill
        mainStackView.alignment = .fill
        mainStackView.spacing = 8
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainStackView)

        // Configure Bottom Stack View
        bottomStackView.axis = .horizontal
        bottomStackView.distribution = .fill
        bottomStackView.alignment = .center
        bottomStackView.spacing = 16

        // Configure Labels
        configureLabels()

        // Add labels to Stack Views
        mainStackView.addArrangedSubview(titleLabel)
        bottomStackView.addArrangedSubview(timeLabel)
        bottomStackView.addArrangedSubview(venueLabel)
        mainStackView.addArrangedSubview(bottomStackView)

        // Set up Auto Layout constraints for the main stack view
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    private func configureLabels() {
        // Title Label
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        titleLabel.numberOfLines = 0 // Allow title to wrap to multiple lines if necessary
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        // Time Label
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = .gray
        timeLabel.textAlignment = .left
        timeLabel.numberOfLines = 1
        timeLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        timeLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // Venue Label
        venueLabel.font = UIFont.systemFont(ofSize: 12)
        venueLabel.textColor = .gray
        venueLabel.textAlignment = .right
        venueLabel.numberOfLines = 1
        venueLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        venueLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
}
