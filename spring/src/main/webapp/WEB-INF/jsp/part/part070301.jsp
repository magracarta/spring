<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 코드관리 > 부품CUBE > 부품SET > null
-- 작성자 : 박예진
-- 최초 작성일 : 2020-01-10 17:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		$(document).ready(function() {
			createAUIGrid();
			goSearch();
		});
	
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColumn: true,
				treeColumnIndex : 2,
				headerHeight : 40,
				// 최초 보여질 때 모두 열린 상태로 출력 여부
				displayTreeOpen : false,
			};
			var columnLayout = [
				{ 
					headerText : "SET명", 
					dataField : "set_name", 
					width : "210",
					minWidth : "210",
					style : "aui-left aui-popup",
				},
				{ 
					headerText : "부품번호", 
					dataField : "part_no", 
					width : "150",
					minWidth : "150",
					style : "aui-left"
				},
				{ 
					headerText : "부품명", 
					dataField : "part_name", 
					width : "250",
					minWidth : "250",
					style : "aui-left"
				},				
				{ 
					headerText : "수량", 
					dataField : "qty",
					dataType : "numeric",
					formatString : "#,##0",
					width : "50",
					minWidth : "50",
					style : "aui-center"
				},
				{ 
					headerText : "VIP가<br>(VAT별도)", 
					dataField : "vip_sale_price",
					dataType : "numeric",
					onlyNumeric : true,
					formatString : "#,##0",
					width : "85",
					minWidth : "85", 
					style : "aui-right",
				},
				{ 
					headerText : "합계 VIP가", 
					dataField : "total_vip_sale_price",
					dataType : "numeric",
					onlyNumeric : true,
					formatString : "#,##0",
					width : "85",
					minWidth : "85", 
					style : "aui-right",
				},
				{ 
					headerText : "일반가<br>(VAT별도)", 
					dataField : "sale_price",
					dataType : "numeric",
					onlyNumeric : true,
					formatString : "#,##0",
					width : "85",
					minWidth : "85",
					style : "aui-right",
				},
				{ 
					headerText : "합계 일반가", 
					dataField : "total_sale_price",
					dataType : "numeric",
					onlyNumeric : true,
					formatString : "#,##0",
					width : "85",
					minWidth : "85",
					style : "aui-right",
				},
				{
					headerText : "등록일", 
					dataField : "reg_dt", 
					dataType : "date",  
					formatString : "yy-mm-dd",
					width : "65",
					minWidth : "65",
					style : "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						var regDt = AUIGrid.formatDate(value, "yy-mm-dd");
						if(item["seq_depth"] != "1") {
							regDt = "";
						}
				    	return regDt; 
					}
				},
				{ 
					headerText : "작성자", 
					dataField : "reg_mem_name",
					width : "60",
					minWidth : "60",
					style : "aui-center"
				},
				{ 
					headerText : "비고", 
					dataField : "remark",
					width : "150",
					minWidth : "150",
					style : "aui-left"
				},
				{ 
					headerText : "part_set_seq", 
					dataField : "part_set_seq", 
					visible : false
				},
				{ 
					headerText : "seq_depth", 
					dataField : "seq_depth", 
					visible : false
				},
				{ 
					headerText : "seq_no", 
					dataField : "seq_no", 
					visible : false
				},
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "set_name") {
					var param = {
							"part_set_seq" : event.item["part_set_seq"]
						};			
					var popupOption = "";
					$M.goNextPage('/part/part0703p01', $M.toGetParam(param),  {popupStatus : popupOption});
				}
			});	
		}
		
		//조회
		function goSearch() { 
			var param = {
					"s_set_name" : $M.getValue("s_set_name"),
					"s_part_no" : $M.getValue("s_part_no"),
					"s_part_name" : $M.getValue("s_part_name"),
			};
			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
					function(result) {
						if(result.success) {
							AUIGrid.setGridData(auiGrid, result.list);
							$("#total_cnt").html(result.total_cnt);
						};
					}
				);
		} 
	
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_set_name", "s_part_no", "s_part_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}
		
		// 엑셀다운로드
		function fnDownloadExcel() {
			  // 엑셀 내보내기 속성
			  var exportProps = {
			  };
			  fnExportExcel(auiGrid, "부품SET", exportProps);
		}
		
		// SET등록
		function goNew() {
			var popupOption = "";
			$M.goNextPage('/part/part070301p01', "",  {popupStatus : popupOption});
		}
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
<!-- 검색영역 -->					
					<div class="search-wrap mt10">				
						<table class="table table-fixed">
							<colgroup>
								<col width="50px">
								<col width="160px">						
								<col width="65px">
								<col width="100px">
								<col width="55px">
								<col width="100px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>SET명</th>
									<td>
										<input type="text" class="form-control" id="s_set_name" name="s_set_name">
									</td>
									<th>부품번호</th>
									<td>
										<input type="text" class="form-control" id="s_part_no" name="s_part_no">
                                    </td>
                                    <th>부품명</th>
									<td>
										<input type="text" class="form-control" id="s_part_name" name="s_part_name">
									</td>
                                    <td>
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
									</td>															
								</tr>						
							</tbody>
						</table>					
					</div>
<!-- /검색영역 -->	
<!-- 그리드 타이틀, 컨트롤 영역 -->
<!-- /그리드 타이틀, 컨트롤 영역 -->	
					<div class="title-wrap mt10">
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
							</div>
						</div>
					</div>
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">	
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>			
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
<!-- /그리드 서머리, 컨트롤 영역 -->
			</div>		
		</div>
<!-- /contents 전체 영역 -->		
</div>	
</form>
</body>
</html>