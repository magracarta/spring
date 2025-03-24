<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ include file="/WEB-INF/jsp/common/commonForAll.jsp" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<!DOCTYPE html> 
	<script type="text/javascript">
		var auiGridMidLeft;
		var auiGridMidRight;
		var auiGridBomLeft;
		var auiGridBomRight;
		
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGridMidLeft();
			createAUIGridMidRight();
			createAUIGridBomLeft();
			createAUIGridBomRight();
		});
	
		// 수주확정
		function createAUIGridMidLeft() {
			var gridPros = {
					showRowNumColumn : true,
					rowIdField : "_$uid",
					treeColumnIndex : 4,
					editable : false
			};
			
			var columnLayout = [
				{ 
					headerText : "수주일자", 
					dataField : "sale_dt", 
					width : "13%",
					dataType : "date",
					formatString : "yyyy-mm-dd",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var saleDt = AUIGrid.formatDate(value, "yyyy-mm-dd");
						if(item["seq_depth"] != "1") {
							saleDt = "";
						}
				    	return saleDt; 
					}
				},
				{ 
					headerText : "수주구분", 
					dataField : "part_sale_type", 
					width : "8%",
					style : "aui-center"
				},
				{ 
					headerText : "고객명", 
					dataField : "cust_name",
					width : "12%",
					style : "aui-center"
				},
				{ 
					headerText : "품번", 
					dataField : "part_no",
					width : "13%",
					style : "aui-left aui-popup"
				},
				{
					dataField : "part_sale_no",
					visible   : false,
				},
				{
					dataField : "cust_no",
					visible   : false,
				},
				{ 
					headerText : "품명", 
					dataField : "part_name", 
					width : "20%",
					style : "aui-left"
				},
				{
					headerText : "배송희망일", 
					dataField : "delivery_plan_dt", 
					dataType : "date",  
					formatString : "yyyy-mm-dd", 
					width : "13%",
					style : "aui-center",
				},
				{
					headerText : "금액",
					dataField : "total_amt",
					dataType : "numeric",
					formatString : "#,##0",
					width : "12%", 
					style : "aui-right",
				},
				{
					headerText : "입금여부", 
					dataField : "inout_gubun", 
					width : "8%",
					style : "aui-center",
				},
				{
					headerText : "입금일", 
					dataField : "inout_dt", 
					dataType : "date",  
					formatString : "yyyy-mm-dd", 
					width : "13%",
					style : "aui-center",
				},
				{
					headerText : "진행상태", 
					dataField : "part_sale_status_name", 
					width : "10%",
					style : "aui-center",
				}
			];
			
			
			// 실제로 #grid_wrap에 그리드 생성
			auiGridMidLeft = AUIGrid.create("#auiGridMidLeft", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridMidLeft, ${partList1});
			AUIGrid.bind(auiGridMidLeft, "cellClick", function(event) {
				if(event.dataField == 'part_no') {
					var param = {
						"part_sale_no" : event.item["part_sale_no"],
						"cust_no" 	   : event.item["cust_no"],
					};
					var popupOption = "";
					$M.goNextPage('/cust/cust0201p01', $M.toGetParam(param), {popupStatus : popupOption});
				}
			}); 
		}
		
		// 발주요청
		function createAUIGridMidRight() {
			var gridPros = {
					showRowNumColumn : true,
					rowIdField : "_$uid",
					editable : false
			};
			
			var columnLayout = [
				{ 
					headerText : "요청센터", 
					dataField : "req_order_org_name", 
					width : "10%",
					style : "aui-center"
				},
				{ 
					headerText : "요청자", 
					dataField : "request_mem_name", 
					width : "8%",
					style : "aui-center"
				},
				{ 
					headerText : "요청일자", 
					dataField : "req_dt", 
					dataType : "date",  
					formatString : "yyyy-mm-dd", 
					width : "13%",
					style : "aui-center"
				},
				{ 
					headerText : "요청구분", 
					dataField : "part_preorder_type_name",
					width : "9%",
					style : "aui-center"
				},
				{ 
					headerText : "부품명", 
					dataField : "part_name", 
					width : "18%",
					style : "aui-left"
				},
				{
					headerText : "상태", 
					dataField : "part_preorder_status_name", 
					width : "8%",
					style : "aui-center",
				},
				{
					headerText : "발주처리일", 
					dataField : "order_proc_dt",  
					dataType : "date",  
					formatString : "yyyy-mm-dd", 
					width : "13%",
					style : "aui-center",
				},
				{
					headerText : "발주번호", 
					dataField : "part_order_no", 
					style : "aui-center"
				}
			];
			
			
			// 실제로 #grid_wrap에 그리드 생성
			auiGridMidRight = AUIGrid.create("#auiGridMidRight", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridMidRight, ${partList2});
		}
		
		// 미출하부품
		function createAUIGridBomLeft() {
			var gridPros = {
					showRowNumColumn : true,
					rowIdField : "_$uid",
					editable : false
			};
			
			var columnLayout = [
				{ 
					headerText : "전표일자", 
					dataField : "inout_dt",  
					dataType : "date",  
					formatString : "yyyy-mm-dd", 
					width : "13%",
					style : "aui-center"
				},
				{ 
					headerText : "고객명", 
					dataField : "cust_name", 
					width : "12%",
					style : "aui-center"
				},
				{ 
					headerText : "품명", 
					dataField : "part_name",
					style : "aui-left"
				},
				{ 
					headerText : "금액", 
					dataField : "",
					dataType : "numeric",
					formatString : "#,##0",
					width : "12%", 
					style : "aui-right"
				},
				{ 
					headerText : "입금여부", 
					dataField : "",
					width : "10%",
					style : "aui-center"
				},
				{ 
					headerText : "진행상태", 
					dataField : "",
					width : "10%",
					style : "aui-center"
				},
				{ 
					headerText : "입금일", 
					dataField : "",  
					dataType : "date",  
					formatString : "yyyy-mm-dd", 
					width : "13%",
					style : "aui-center"
				}
			];
			
			// 실제로 #grid_wrap에 그리드 생성
			auiGridBomLeft = AUIGrid.create("#auiGridBomLeft", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridBomLeft, []);
		}
		
		// 재고 1 이하 부품(전일 판매 기준)
		function createAUIGridBomRight() {
			var gridPros = {
					showRowNumColumn : true,
					editable : false,
					rowIdField : "_$uid",
			};
			
			var columnLayout = [
				{ 
					headerText : "부품번호", 
					dataField : "part_no", 
					width : "15%",
					style : "aui-center"
				},
				{ 
					headerText : "부품명", 
					dataField : "part_name", 
					style : "aui-left"
				},
				{ 
					headerText : "현재고", 
					dataField : "mon_ed_stock",
					dataType : "numeric",
					formatString : "#,##0",
					width : "10%",
					style : "aui-right"
				},
				{ 
					headerText : "당해판매", 
					dataField : "year1_qty",
					dataType : "numeric",
					formatString : "#,##0",
					width : "10%",
					style : "aui-right"
				},
				{ 
					headerText : "전년판매", 
					dataField : "year2_qty",
					dataType : "numeric",
					formatString : "#,##0",
					width : "10%",
					style : "aui-right"
				},
				{ 
					headerText : "전전년판매", 
					dataField : "year3_qty",
					dataType : "numeric",
					formatString : "#,##0",
					width : "10%",
					style : "aui-right"
				},
				{ 
					headerText : "관리구분", 
					dataField : "part_mng_name",
					width : "10%",
					style : "aui-center",
					renderer : {
						type : "TemplateRenderer"
					},
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						if(item["part_mng_name"] == "장기재고" || item["part_mng_name"] == "충당재고") {
							var template = '<div>' + '<span style="color:red";>' + item.part_mng_name + '</span>' + '</div>';
							return template;
						} else {
						   var template = '<div>' + '<span style="color:black";>' + item.part_mng_name + '</span>' + '</div>';
						   return template;
						}
					},
				},
			];
			// 실제로 #grid_wrap에 그리드 생성
			auiGridBomRight = AUIGrid.create("#auiGridBomRight", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridBomRight, ${partList4});
		}
	</script>

						<div class="row">
							<div class="col-6">
								<div class="title-wrap mt10">
									<h4>수주확정(30일 이전)
										<span class="text-warning">※(성능개선 후 표기됨)</span> 
									</h4>
									<button type="button" class="btn btn-default" onclick="javascript:goMain('수주현황/등록', '/cust/cust0201');"><i class="material-iconskeyboard_arrow_right text-default"></i>바로가기</button>
								</div>
								<div id="auiGridMidLeft" style="margin-top: 5px; height: 250px;"></div>
							</div>
							<div class="col-6">
								<div class="title-wrap mt10">
									<h4>발주요청(30일 이전)
										<span class="text-warning">※(성능개선 후 표기됨)</span> 
									</h4>
									<button type="button" class="btn btn-default" onclick="javascript:goMain('부품발주요청', '/part/part0401');"><i class="material-iconskeyboard_arrow_right text-default"></i>바로가기</button>
								</div>
								<div id="auiGridMidRight" style="margin-top: 5px; height: 250px;"></div>
							</div>
						</div>
						<div class="row">
							<div class="col-6">
								<div class="title-wrap mt10">
									<h4>미출하부품
										<span class="text-warning">※(성능개선 후 표기됨)</span> 
									</h4>
									<button type="button" class="btn btn-default" onclick="javascript:alert('준비중입니다.');"><i class="material-iconskeyboard_arrow_right text-default"></i>바로가기</button>
								</div>
								<div id="auiGridBomLeft" style="margin-top: 5px; height: 250px;"></div>
							</div>
							<div class="col-6">
								<div class="title-wrap mt10">
									<h4>재고 1 이하 부품(전일 판매 기준)
										<span class="text-warning">※(성능개선 후 표기됨)</span> 
									</h4>
								</div>
								<div id="auiGridBomRight" style="margin-top: 5px; height: 250px;"></div>
							</div>
						</div>
