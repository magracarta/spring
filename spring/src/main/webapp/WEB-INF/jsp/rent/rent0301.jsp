<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈비용 > 렌탈비관리-장비 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-05-21 20:04:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;
		var priceMonCd = JSON.parse('${codeMapJsonObj['RENTAL_PRICE_MON']}');
		console.log(priceMonCd);
		
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
			var myEditRenderer = {
					type : "DropDownListRenderer",
					// showEditorBtnOver : true,
					showEditorBtn : false,
					showEditorBtnOver : false,
					editable : true,
					list : priceMonCd,
					// historyMode : true, // 히스토리 모드 사용
					keyField : "code_value",
					valueField  : "code_name"
					
			};
			var columnLayout = [
				{ 
					dataField : "machine_plant_seq", 
					visible : false,
				},
				/* {
					dataField : "rental_price_mon_cd",
					visible : false
				}, */
				{ 
					headerText : "메이커", 
					dataField : "maker_name", 
					editable : false,
					width : "55", 
					minWidth : "45",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "모델명", 
					dataField : "machine_name", 
					editable : false,
					width : "105", 
					minWidth : "45",
					style : "aui-left",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "운영기간",
					dataField : "rental_price_mon_cd",
					editable : false, // 제한변경 불가하게 수정!(얀마는 연령별, 얀마 아닌건 연령제한없음으로 고정됨~)
					width : "145", 
					minWidth : "45",
					editRenderer : {
						type : "ConditionRenderer",
						conditionFunction : function(rowIndex, columnIndex, value, item, dataField) {
								return myEditRenderer;
						}
					},
					labelFunction : function(  rowIndex, columnIndex, value, headerText, item ) { 
						var retStr = value;
						for(var j = 0; j < priceMonCd.length; j++) {
							if(priceMonCd[j]["code_value"] == value) {
								retStr = priceMonCd[j]["code_name"];
								break;
							}
						}
						return retStr;
					},
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "적용일",
					dataField : "price_dt",
					editable : false,
					dataType : "date",  
					dataInputString : "yyyymmdd",
					formatString : "yy-mm-dd",
					width : "75", 
					minWidth : "75",
					style : "aui-center",
					filter : {
						showIcon : true
					}
				},			
				{
					headerText : "1일",
					children : [
						{
							headerText : "평균", 
							dataField : "avg1_price", 
							dataType : "numeric",
							width : "85", 
							minWidth : "45", 
							style : "aui-right",
							editable : false,
							required : true,
							filter : {
								showIcon : true
							}
						}, 
						{
							headerText : "결정", 
							dataField : "rental1_price", 
							dataType : "numeric",
							width : "85", 
							minWidth : "45", 
							style : "aui-right aui-editable",
							editable : true,
							required : true,
							editRenderer : {
							    type : "InputEditRenderer",
							    onlyNumeric : true,
					     	 	maxlength : 20,
						      	// 에디팅 유효성 검사
						      	validator : AUIGrid.commonValidator
							},
							filter : {
								showIcon : true
							}
						}
					]
				},				
				{
					headerText : "7일",
					children : [
						{
							headerText : "평균", 
							dataField : "avg7_price", 
							dataType : "numeric",
							width : "85", 
							minWidth : "45", 
							style : "aui-right",
							editable : false,
							required : true,
							filter : {
								showIcon : true
							}
						},
						{
							headerText : "결정", 
							dataField : "rental7_price", 
							dataType : "numeric",
							width : "85", 
							minWidth : "45", 
							style : "aui-right aui-editable",
							editable : true,
							required : true,
							editRenderer : {
							    type : "InputEditRenderer",
							    onlyNumeric : true,
					     	 	maxlength : 20,
						      	// 에디팅 유효성 검사
						      	validator : AUIGrid.commonValidator
							},
							filter : {
								showIcon : true
							}
						}
					]
				},	
				{
					headerText : "15일",
					children : [
						{
							headerText : "평균", 
							dataField : "avg15_price", 
							dataType : "numeric",
							width : "85", 
							minWidth : "45", 
							style : "aui-right",
							editable : false,
							required : true,
							filter : {
								showIcon : true
							}
						},
						{
							headerText : "결정", 
							dataField : "rental15_price", 
							dataType : "numeric",
							width : "85", 
							minWidth : "45", 
							style : "aui-right aui-editable",
							editable : true,
							required : true,
							editRenderer : {
							    type : "InputEditRenderer",
							    onlyNumeric : true,
					     	 	maxlength : 20,
						      	// 에디팅 유효성 검사
						      	validator : AUIGrid.commonValidator
							},
							filter : {
								showIcon : true
							}
						}
					]
				},	
				{
					headerText : "30일",
					children : [
						{
							headerText : "평균", 
							dataField : "avg30_price", 
							dataType : "numeric",
							width : "85", 
							minWidth : "45", 
							style : "aui-right",
							editable : false,
							required : true,
							filter : {
								showIcon : true
							}
						},
						{
							headerText : "결정", 
							dataField : "rental30_price", 
							dataType : "numeric",
							width : "85", 
							minWidth : "45", 
							style : "aui-right aui-editable",
							editable : true,
							required : true,
							editRenderer : {
							    type : "InputEditRenderer",
							    onlyNumeric : true,
					     	 	maxlength : 20,
						      	// 에디팅 유효성 검사
						      	validator : AUIGrid.commonValidator
							},
							filter : {
								showIcon : true
							}
						}
					]
				},
// 				{
// 					headerText : "사용여부", 
// 					dataField : "use_yn", 
//  					width : "5%",
// 					renderer : {
// 						type : "CheckBoxEditRenderer",
// 						editable : true,
// 						checkValue : "Y",
// 						unCheckValue : "N"
// 					}
// 				}				
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();
		}
		

		function goSearch() {
			var param = {
				"s_maker_cd" : $M.getValue("s_maker_cd")
				, "s_machine_plant_seq" : $M.getValue("s_machine_plant_seq")
				, "s_use_yn" : $M.getValue("s_use_yn")
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
	
		// 저장
		function goSave() {
			var gridFrm = fnChangeGridDataToForm(auiGrid);
			$M.setValue(gridFrm, 'use_yn', 'Y');
			
			if(0 == gridFrm.length) {
				alert("변경된 값이 없습니다.");
				return false;
			}
			for(var i in gridFrm) {
				try {
					var id = gridFrm[i].id;
					var val = gridFrm[i].value;
					if("reduce_price" == id) {
						if("" == val || null == val) {
							alert("감가는 필수 입력입니다.");
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
						alert("저장이 완료되었습니다.");
						goSearch();
					}
				}
			);
		}
		
		// 그리드 필수체크
		function isValid() {
			var msg = "필수 항목은 반드시 값을 입력해야 합니다.";
			// 기본 필수 체크
			var reqField = ["rental1_price", "rental7_price","rental15_price","rental30_price"];
			return AUIGrid.validateGridData(auiGrid, reqField, msg);
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
	<!-- 기본 -->					
				<div class="search-wrap">				
					<table class="table">
						<colgroup>							
							<col width="50px">
							<col width="70px">
							<col width="40px">
							<col width="160px">
<%-- 							<col width="65px"> --%>
<%-- 							<col width="130px"> --%>
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
<!-- 								<th>사용구분</th> -->
<!-- 								<td> -->
<!-- 									<select class="form-control" id="s_use_yn" name="s_use_yn"> -->
<!-- 										<option value="Y">사용</option> -->
<!-- 										<option value="N">미사용</option> -->
<!-- 									</select> -->
<!-- 								</td> -->
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch()"  >조회</button>
								</td>									
							</tr>						
						</tbody>
					</table>					
				</div>
	<!-- /기본 -->	
	<!-- 그리드 타이틀, 컨트롤 영역 -->
				<div class="title-wrap mt10">
					<h4>조회결과</h4>
					<div class="btn-group">
						<div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
						</div>
					</div>
				</div>
	<!-- /그리드 타이틀, 컨트롤 영역 -->					
				<div  id="auiGrid"  style="margin-top: 5px; height: 555px;"></div>
	<!-- 그리드 서머리, 컨트롤 영역 -->
				<div class="btn-group mt5">
					<div class="left">
						총 <strong class="text-primary" id="total_cnt">0</strong>건
					</div>						
					<div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>
				</div>
	<!-- /그리드 서머리, 컨트롤 영역 -->
			</div>
		</div>	
		<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>		
	</div>
<!-- /contents 전체 영역 -->	
</div>	
</form>
</body>
</html>