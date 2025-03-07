package hello.core2.Order;

public interface OrderService {
    Order createOrder(Long memberId, String itemName, int itemPrice);

}
