<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈비용 > 중고시세관리 > null > null
-- 작성자 : 김상덕
-- 최초 작성일 : 2020-05-21 20:04:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGrid();
		});
	
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				editable : true,
				// rowIdField 설정
				rowIdField : "_$uid", 
				// rowIdField가 unique 임을 보장
				rowIdTrustMode : true,
				// rowNumber 
				showRowNumColumn : true,
				enableSorting : true,
				showStateColumn : true,
				enableFilter : true			
			};
			var columnLayout = [
				{ 
					headerText : "메이커", 
					dataField : "maker_name", 
					width : "70", 
					minWidth : "60",
					style : "aui-center",
					editable : false,
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "모델명", 
					dataField : "machine_name", 
					width : "110", 
					minWidth : "60",
					style : "aui-left",
					editable : false,
					required : false,
					filter : {
						showIcon : true
					}
				},	
				{
					headerText : "판매가",
					dataField : "sale_price", 		
					dataType : "numeric",
					width : "80", 
					minWidth : "60",
					style : "aui-center  aui-editable",
					editable : true,
					required : true,
					formatString : "#,##0",
					editRenderer : {
				    	type : "InputEditRenderer",
					    onlyNumeric : true
					},
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "중고시세",
					children : [
						{
							headerText : "12개월", 
							dataField : "used1_price", 
							style : "aui-right aui-editable",
							dataType : "numeric",
							width : "80", 
							minWidth : "60",
							formatString : "#,##0",
							editRenderer : {
						    	type : "InputEditRenderer",
							    onlyNumeric : true
							},
							filter : {
								showIcon : true
							}
						},
						{
							headerText : "24개월", 
							dataField : "used2_price", 
							style : "aui-right aui-editable",
							dataType : "numeric",
							width : "80", 
							minWidth : "60",
							formatString : "#,##0",
							editRenderer : {
						    	type : "InputEditRenderer",
							    onlyNumeric : true
							},
							filter : {
								showIcon : true
							}
						},
						{
							headerText : "36개월", 
							dataField : "used3_price", 
							style : "aui-right aui-editable",
							dataType : "numeric",
							width : "80", 
							minWidth : "60",
							formatString : "#,##0",
							editRenderer : {
						    	type : "InputEditRenderer",
							    onlyNumeric : true
							},
							filter : {
								showIcon : true
							}
						},
						{
							headerText : "48개월", 
							dataField : "used4_price", 
							style : "aui-right aui-editable",
							dataType : "numeric",
							width : "80", 
							minWidth : "60",
							formatString : "#,##0",
							editRenderer : {
						    	type : "InputEditRenderer",
							    onlyNumeric : true
							},
							filter : {
								showIcon : true
							}
						},
						{
							headerText : "60개월", 
							dataField : "used5_price", 
							style : "aui-right aui-editable",
							dataType : "numeric",
							width : "80", 
							minWidth : "60",
							formatString : "#,##0",
							editRenderer : {
						    	type : "InputEditRenderer",
							    onlyNumeric : true
							},
							filter : {
								showIcon : true
							}
						},
						{
							headerText : "72개월", 
							dataField : "used6_price", 
							style : "aui-right aui-editable",
							dataType : "numeric",
							width : "80", 
							minWidth : "60",
							formatString : "#,##0",
							editRenderer : {
						    	type : "InputEditRenderer",
							    onlyNumeric : true
							},
							filter : {
								showIcon : true
							}
						},						
						{
							headerText : "84개월", 
							dataField : "used7_price", 
							style : "aui-right aui-editable",
							dataType : "numeric",
							width : "80", 
							minWidth : "60",
							formatString : "#,##0",
							editRenderer : {
						    	type : "InputEditRenderer",
							    onlyNumeric : true
							},
							filter : {
								showIcon : true
							}
						},
						{
							headerText : "96개월", 
							dataField : "used8_price", 
							style : "aui-right aui-editable",
							dataType : "numeric",
							width : "80", 
							minWidth : "60",
							formatString : "#,##0",
							editRenderer : {
						    	type : "InputEditRenderer",
							    onlyNumeric : true
							},
							filter : {
								showIcon : true
							}
						},
						{
							headerText : "108개월", 
							dataField : "used9_price", 
							style : "aui-right aui-editable",
							dataType : "numeric",
							width : "80", 
							minWidth : "60",
							formatString : "#,##0",
							editRenderer : {
						    	type : "InputEditRenderer",
							    onlyNumeric : true
							},
							filter : {
								showIcon : true
							}
						},
						{
							headerText : "120개월", 
							dataField : "used10_price", 
							style : "aui-right aui-editable",
							dataType : "numeric",
							width : "80", 
							minWidth : "60",
							formatString : "#,##0",
							editRenderer : {
						    	type : "InputEditRenderer",
							    onlyNumeric : true
							},
							filter : {
								showIcon : true
							}
						},
						{
							headerText : "120개월 이상", 
							dataField : "used10_over_price", 
							style : "aui-right aui-editable",
							dataType : "numeric",
							width : "80", 
							minWidth : "60",
							formatString : "#,##0",
							editRenderer : {
						    	type : "InputEditRenderer",
							    onlyNumeric : true
							},
							filter : {
								showIcon : true
							}
						},
						{
							dataField : "machine_plant_seq", 
							visible : false
						},
						{
							dataField : "seq_no", 
							visible : false
						}
					]
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
		}	
		
		function goSearch() {
			var param = {
				"s_maker_cd" : $M.getValue("s_maker_cd"),
				"s_machine_plant_seq" : $M.getValue("s_machine_plant_seq")
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					}
				}
			);
		}
	
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "중고시세관리-장비");
	    }
			
		// 저장
		function goSave() {
			var gridFrm = fnChangeGridDataToForm(auiGrid);
			if(0 == gridFrm.length) {
				alert("변경된 값이 없습니다.");
				return false;
			}
			for(var i in gridFrm) {
				try {
					var id = gridFrm[i].id;
					var val = gridFrm[i].value;
					if("sale_price" == id) {
						if("" == val || null == val || "0" == val) {
							alert("판매가는 필수 입력입니다.");
							return false;
						} else {
							break;
						}
					}
				} catch (e) {
					console.log(e);
				}
			}
			$M.goNextPageAjaxSave(this_page + '/save', gridFrm , {method : 'POST'},
				function(result) {
					if(result.success) {
						AUIGrid.resetUpdatedItems(auiGrid);
					}
				}
			);
		}
	
	
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
<!-- 메인 타이틀 -->
				<div class="main-title">
					<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
				</div>
<!-- /메인 타이틀 -->
				<div class="contents">			
<!-- 검색영역 -->					
					<div class="search-wrap">				
						<table class="table">
							<colgroup>							
								<col width="50px">
								<col width="75px">
								<col width="40px">
								<col width="160px">
								<col width="">
							</colgroup>
							<tbody>
								<tr>
									<th>메이커</th>
									<td>
										<select class="form-control" id="s_maker_cd" name="s_maker_cd">
											<option value="">- 전체 -</option>
											<c:forEach items="${codeMap['MAKER']}" var="item">
												<c:if test="${item.code_v1 eq 'Y' && item.code_v2 eq 'Y'}">
													<option value="${item.code_value}" <c:if test="${result.maker_cd == item.code_value}">selected</c:if>>${item.code_name}</option>
												</c:if>
											</c:forEach>
										</select>
									</td>
									<th>모델</th>
									<td>
										<div class="form-row inline-pd">
											<div class="col-12">
												<div class="input-group">
													<jsp:include page="/WEB-INF/jsp/common/searchMachine.jsp">
														<jsp:param name="required_field" value="s_machine_name"/>
														<jsp:param name="s_sale_yn" value="N"/>
							                     	</jsp:include>						
												</div>
											</div>	
										</div>
									</td>
									<td>
										<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch()" >조회</button>
									</td>									
								</tr>						
							</tbody>
						</table>					
					</div>
<!-- /검색영역 -->
<!-- 조회결과 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
<!-- /조회결과 -->
					<div  id="auiGrid"  style="margin-top: 5px; height: 555px;"></div>					
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>				
				</div>
			</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>		
		</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>