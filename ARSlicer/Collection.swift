import Foundation
import UIKit

struct Shape {
    let name: String
    let imageName: String
}

protocol CollectionIndexDelegate {
    func didScroll(to shape: Shape)
}

class Collection: UICollectionView {
    
    var indexDelegate: CollectionIndexDelegate?
    
    let shapes = [
        Shape(name: "1", imageName: "pizza-1"),
        Shape(name: "2", imageName: "pizza-2"),
        Shape(name: "3", imageName: "pizza-3"),
        Shape(name: "4", imageName: "pizza-4"),
        Shape(name: "5", imageName: "pizza-5")]
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        dataSource = self
        delegate = self
        alwaysBounceHorizontal = true
        backgroundColor = nil
        isOpaque = false
        isPagingEnabled = true
        
        register(Cell.self, forCellWithReuseIdentifier: "cell")
    }
}

extension Collection: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? Cell else { return }
        cell.shape = shapes[indexPath.row]
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shapes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
    }
}


extension Collection: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        update()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if !decelerate {
            update()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        update()
    }
    
    func update() {
        let index: Int = Int(round(contentOffset.x / frame.width))
        indexDelegate?.didScroll(to: shapes[index])
    }
}
