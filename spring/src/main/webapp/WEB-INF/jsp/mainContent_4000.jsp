<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ include file="/WEB-INF/jsp/common/commonForAll.jsp" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<!DOCTYPE html> 
	<script type="text/javascript">
		var auiGridMidLeft;
		var auiGridMidRight;
		var auiGridBom;
		
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGridMidLeft();
			createAUIGridMidRight();
			createAUIGridBom();
		});
	
		function createAUIGridMidLeft() {
			var gridPros = {
					showRowNumColumn : true,
					rowIdField : "_$uid",
					editable : false
			};
			
			var columnLayout = [
				{ 
					headerText : "고객명", 
					dataField : "cust_name", 
					width : "12%",
					style : "aui-center",
				},
				{ 
					headerText : "생일", 
					dataField : "birth_dt", 
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "13%",
					style : "aui-center",
				},
				{ 
					headerText : "휴대폰", 
					dataField : "hp_no",
					width : "16%",
					style : "aui-center",
				},
				{ 
					headerText : "보유모델", 
					dataField : "machine_name",
					style : "aui-center",
				},
				{ 
					headerText : "사용년수", 
					dataField : "use_times", 
					width : "11%",
					style : "aui-center",
				},
				{
					headerText : "최근정비일자", 
					dataField : "repair_finish_dt",  
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "13%",
					style : "aui-center",
				},
				{
					headerText : "가동시간", 
					dataField : "op_hour",
					dataType : "numeric",
					formatString : "#,##0",
					width : "9%",
					style : "aui-center",
				},
				{
					headerText : "안건상담일", 
					dataField : "consult_dt",  
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "13%",
					style : "aui-center",
				}
			];
			
			// 실제로 #grid_wrap에 그리드 생성
			auiGridMidLeft = AUIGrid.create("#auiGridMidLeft", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridMidLeft, ${custList1});
			AUIGrid.bind(auiGridMidLeft, "cellClick", function(event) {

			}); 
		}
		
		function createAUIGridMidRight() {
			var gridPros = {
					showRowNumColumn : true,
					rowIdField : "_$uid",
					editable : false
			};
			
			var columnLayout = [
				{ 
					headerText : "정비일", 
					dataField : "repair_finish_dt",   
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "13%",
					style : "aui-center"
				},
				{ 
					headerText : "고객명", 
					dataField : "cust_name", 
					width : "14%",
					style : "aui-center"
				},
				{ 
					headerText : "휴대폰", 
					dataField : "hp_no",
					width : "18%",
					style : "aui-center",
				},
				{ 
					headerText : "모델명", 
					dataField : "machine_name",
					style : "aui-center"
				},
				{ 
					headerText : "판매일", 
					dataField : "sale_dt",   
					dataType : "date",
					formatString : "yyyy-mm-dd",
					width : "13%",
					style : "aui-center"
				},
				{ 
					headerText : "가동시간", 
					dataField : "op_hour", 
					width : "10%",
					style : "aui-center"
				},
				{
					headerText : "처리센터", 
					dataField : "org_name", 
					width : "13%",
					style : "aui-center",
				}
			];
			
			// 실제로 #grid_wrap에 그리드 생성
			auiGridMidRight = AUIGrid.create("#auiGridMidRight", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridMidRight, ${custList2});
		}
		
		function createAUIGridBom() {
			var gridPros = {
					showRowNumColumn : true,
					rowIdField : "_$uid",
					editable : false
			};
			
			var columnLayout = [
				{ 
					headerText : "가상계좌번호", 
					dataField : "virtual_account_no", 
					width : "25%",
					style : "aui-center"
				},
				{ 
					headerText : "고객명", 
					dataField : "cust_name", 
					style : "aui-center"
				},
				{ 
					headerText : "입금액", 
					dataField : "deposit_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "25%",
					style : "aui-right"
				},
				{ 
					headerText : "장비대", 
					dataField : "total_vat_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "25%",
					style : "aui-right"
				}
			];
			
			// 실제로 #grid_wrap에 그리드 생성
			auiGridBom = AUIGrid.create("#auiGridBom", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridBom, ${custlist3});
		}
		
	</script>

						<div class="row">
							<div class="col-6">
								<div class="title-wrap mt10">
									<h4>마케팅대상고객
										<span class="text-warning">※(성능개선 후 표기됨)</span> 
									</h4>
									<button type="button" class="btn btn-default" onclick="javascript:goMain('마케팅대상고객', '/cust/cust0101');"><i class="material-iconskeyboard_arrow_right text-default"></i>바로가기</button>
								</div>
								<div id="auiGridMidLeft" style="margin-top: 5px; height: 250px;"></div>
							</div>
							<div class="col-6">
								<div class="title-wrap mt10">
									<h4>고객수리내역(전일, 당일 기준)
										<span class="text-warning">※(성능개선 후 표기됨)</span> 
									</h4>
									<button type="button" class="btn btn-default" onclick="javascript:goMain('정비지시서', '/serv/serv0101');"><i class="material-iconskeyboard_arrow_right text-default"></i>바로가기</button>
								</div>
								<div id="auiGridMidRight" style="margin-top: 5px; height: 250px;"></div>
							</div>
						</div>
						<div class="row">
							<div class="col-6">
								<div class="title-wrap mt10">
									<h4>가상계좌입금(30일)
										<span class="text-warning">※(성능개선 후 표기됨)</span> 
									</h4>
									<button type="button" class="btn btn-default" onclick="javascript:goMain('계좌입출금내역', '/cust/cust0303');"><i class="material-iconskeyboard_arrow_right text-default"></i>바로가기</button>
								</div>
								<div id="auiGridBom" style="margin-top: 5px; height: 250px;"></div>
							</div>
							<div class="col-6">
								<div class="title-wrap mt10">
									<h4><span class="text-primary">${SecureUser.kor_name}</span>님 장비판매현황</h4>
								</div>
								<div class="mt7 pl10">
									<img src="/static/img/google-analytics.jpg" alt="구글애널리틱스 영역" style="width: 100%;">
								</div>
							</div>
						</div>
