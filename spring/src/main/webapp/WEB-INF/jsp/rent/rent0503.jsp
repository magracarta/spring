<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 이동/재렌탈 > 재렌탈 가격등록 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-05-21 20:04:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		var auiGrid;
		$(document).ready(function () {
			createAUIGrid();
		});
		
		function createAUIGrid() {
			var gridPros = {
				// Row번호 표시 여부
				showRowNumColum : true,
				editable : true,
				enableFilter : true	
			};
	
			var columnLayout = [
				{
					headerText : "메이커",
					dataField : "maker_name",
					style : "aui-center",
					width : "65",
					minWidth : "60",
					editable : false,
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "모델명",
					dataField : "machine_name",
					style : "aui-left",
					editable : false,
					width : "120",
					minWidth : "120",
					filter : {
						showIcon : true
					}
				},
				/*
				{
					headerText : "산출기준가",
					dataField : "base_price",
					dataType : "numeric",
					style : "aui-center",
					formatString : "#,##0",
					editable : false,
					width : "8%"
				}, */
				{
					headerText : "재렌탈 등록 기준가",
					dataField : "g",
					children : [
						{
							headerText : "1개월",
							dataField : "mon1_price",
							dataType : "numeric",
							editable : true,
							editRenderer : {
								type : "InputEditRenderer",
								onlyNumeric : true,
								autoThousandSeparator : true, // 천단위 구분자 삽입 여부 (onlyNumeric=true 인 경우 유효)
								allowPoint : false, // 소수점(.) 입력 가능 설정
							},
							style : "aui-center aui-editable",
							width : "100",
							minWidth : "100",
							formatString : "#,##0",
							filter : {
								showIcon : true
							}
						},
						{
							headerText : "2개월",
							dataField : "mon2_price",
							dataType : "numeric",
							editable : true,
							editRenderer : {
								type : "InputEditRenderer",
								onlyNumeric : true,
								autoThousandSeparator : true, // 천단위 구분자 삽입 여부 (onlyNumeric=true 인 경우 유효)
								allowPoint : false, // 소수점(.) 입력 가능 설정
							},
							style : "aui-center aui-editable",
							width : "100",
							minWidth : "100",
							formatString : "#,##0",
							filter : {
								showIcon : true
							}
						},
						{
							headerText : "3개월",
							dataField : "mon3_price",
							dataType : "numeric",
							editable : true,
							editRenderer : {
								type : "InputEditRenderer",
								onlyNumeric : true,
							    autoThousandSeparator : true, // 천단위 구분자 삽입 여부 (onlyNumeric=true 인 경우 유효)
							    allowPoint : false, // 소수점(.) 입력 가능 설정
							},
							style : "aui-center aui-editable",
							width : "100",
							minWidth : "100",
							formatString : "#,##0",
							filter : {
								showIcon : true
							}
						},
						{
							headerText : "4개월",
							dataField : "mon4_price",
							dataType : "numeric",
							width : "100",
							minWidth : "100",
							editable : true,
							editRenderer : {
								type : "InputEditRenderer",
								onlyNumeric : true,
								autoThousandSeparator : true, // 천단위 구분자 삽입 여부 (onlyNumeric=true 인 경우 유효)
								allowPoint : false, // 소수점(.) 입력 가능 설정
							},
							style : "aui-center aui-editable",
							formatString : "#,##0",
							filter : {
								showIcon : true
							}
						},
						{
							headerText : "5개월",
							dataField : "mon5_price",
							dataType : "numeric",
							width : "100",
							minWidth : "100",
							editable : true,
							editRenderer : {
								type : "InputEditRenderer",
								onlyNumeric : true,
								autoThousandSeparator : true, // 천단위 구분자 삽입 여부 (onlyNumeric=true 인 경우 유효)
								allowPoint : false, // 소수점(.) 입력 가능 설정
							},
							style : "aui-center aui-editable",
							formatString : "#,##0",
							filter : {
								showIcon : true
							}
						},
						{
							headerText : "6개월",
							dataField : "mon6_price",
							dataType : "numeric",
							width : "100",
							minWidth : "100",
							editable : true,
							editRenderer : {
								type : "InputEditRenderer",
								onlyNumeric : true,
							    autoThousandSeparator : true, // 천단위 구분자 삽입 여부 (onlyNumeric=true 인 경우 유효)
							    allowPoint : false, // 소수점(.) 입력 가능 설정
							},
							style : "aui-center aui-editable",
							formatString : "#,##0",
							filter : {
								showIcon : true
							}
						},
						{
							headerText : "7개월",
							dataField : "mon7_price",
							dataType : "numeric",
							width : "100",
							minWidth : "100",
							editable : true,
							editRenderer : {
								type : "InputEditRenderer",
								onlyNumeric : true,
								autoThousandSeparator : true, // 천단위 구분자 삽입 여부 (onlyNumeric=true 인 경우 유효)
								allowPoint : false, // 소수점(.) 입력 가능 설정
							},
							style : "aui-center aui-editable",
							formatString : "#,##0",
							filter : {
								showIcon : true
							}
						},
						{
							headerText : "8개월",
							dataField : "mon8_price",
							dataType : "numeric",
							width : "100",
							minWidth : "100",
							editable : true,
							editRenderer : {
								type : "InputEditRenderer",
								onlyNumeric : true,
								autoThousandSeparator : true, // 천단위 구분자 삽입 여부 (onlyNumeric=true 인 경우 유효)
								allowPoint : false, // 소수점(.) 입력 가능 설정
							},
							style : "aui-center aui-editable",
							formatString : "#,##0",
							filter : {
								showIcon : true
							}
						},
						{
							headerText : "9개월",
							dataField : "mon9_price",
							dataType : "numeric",
							width : "100",
							minWidth : "100",
							editable : true,
							editRenderer : {
								type : "InputEditRenderer",
								onlyNumeric : true,
								autoThousandSeparator : true, // 천단위 구분자 삽입 여부 (onlyNumeric=true 인 경우 유효)
								allowPoint : false, // 소수점(.) 입력 가능 설정
							},
							style : "aui-center aui-editable",
							formatString : "#,##0",
							filter : {
								showIcon : true
							}
						},
						{
							headerText : "10개월",
							dataField : "mon10_price",
							dataType : "numeric",
							width : "100",
							minWidth : "100",
							editable : true,
							editRenderer : {
								type : "InputEditRenderer",
								onlyNumeric : true,
								autoThousandSeparator : true, // 천단위 구분자 삽입 여부 (onlyNumeric=true 인 경우 유효)
								allowPoint : false, // 소수점(.) 입력 가능 설정
							},
							style : "aui-center aui-editable",
							formatString : "#,##0",
							filter : {
								showIcon : true
							}
						},
						{
							headerText : "11개월",
							dataField : "mon11_price",
							dataType : "numeric",
							width : "100",
							minWidth : "100",
							editable : true,
							editRenderer : {
								type : "InputEditRenderer",
								onlyNumeric : true,
								autoThousandSeparator : true, // 천단위 구분자 삽입 여부 (onlyNumeric=true 인 경우 유효)
								allowPoint : false, // 소수점(.) 입력 가능 설정
							},
							style : "aui-center aui-editable",
							formatString : "#,##0",
							filter : {
								showIcon : true
							}
						},
						{
							headerText : "12개월",
							dataField : "mon12_price",
							width : "100",
							minWidth : "100",
							dataType : "numeric",
							editable : true,
							editRenderer : {
								type : "InputEditRenderer",
								onlyNumeric : true,
							    autoThousandSeparator : true, // 천단위 구분자 삽입 여부 (onlyNumeric=true 인 경우 유효)
							    allowPoint : false, // 소수점(.) 입력 가능 설정
							},
							style : "aui-center aui-editable",
							formatString : "#,##0",
							filter : {
								showIcon : true
							}
						}
					]
				},
				{
					headerText : "적용일",
					dataField : "price_dt",  
					dataType : "date",   
					style : "aui-center",
					editable : false,
					formatString : "yy-mm-dd",
					width : "75",
					minWidth : "75",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "등록자",
					dataField : "reg_mem_name",
					style : "aui-center",
					editable : false,
					width : "70",
					minWidth : "60",
					filter : {
						showIcon : true
					}
				},
				{
					headerText : "사용여부",
					dataField : "use_yn",
					style : "aui-center",
					width : "75",
					minWidth : "75",
					renderer: {
						type : "CheckBoxEditRenderer",
						showLabel : false,
						editable : true,
						checkValue : "Y",
						unCheckValue : "N"
					},
					filter : {
						showIcon : true
					}
				},
				{
					dataField : "machine_plant_seq",
					visible : false
				}
			];
			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
		}
		
		//엑셀다운로드 버튼
		function fnDownloadExcel() {
		 	var exportProps = {
				//제외항목
			};
			fnExportExcel(auiGrid, "재렌탈가격", exportProps);
		}
		
		// 검색 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_machine_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch(document.main_form);
				};
			});
		}
	
		//조회버튼
		function goSearch() {
			var param = {
				s_maker_cd : $M.getValue("s_maker_cd"),
				s_machine_name : $M.getValue("s_machine_name"),
				s_use_yn : $M.getValue("s_use_yn"),
				s_sort_key : "vm.maker_cd desc, vm.machine_name",
				s_sort_method : "desc"
			};
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						$("#total_cnt").html(result.total_cnt);
						AUIGrid.setGridData(auiGrid, result.list);
					};
				}
			)
		}
		
		//저장버튼
		function goSave() {
			if (fnChangeGridDataCnt(auiGrid) == 0) {
				alert("변경된 데이터가 없습니다.");
				return false;
			};
			var edList = AUIGrid.getEditedRowItems(auiGrid);
			var msg = "저장하시겠습니까?";
			for (var i = 0; i < edList.length; ++i) {
				if (edList[i].use_yn == "N") {
					msg = "사용여부가 체크되지 않은 기준값은 저장되지 않습니다. 저장하시겠습니까?";
					break;
				}
			};
			var frm = fnChangeGridDataToForm(auiGrid);
			$M.goNextPageAjaxMsg(msg, this_page, frm, {method : 'POST'}, 
				function(result) {
					if(result.success) {
						AUIGrid.resetUpdatedItems(auiGrid);
						goSearch();
					};
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
								<col width="55px">
								<col width="75px">	
								<col width="45px">
								<col width="180px">	
								<col width="65px">
								<col width="100px">
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
										<input type="text" class="form-control" id="s_machine_name" name="s_machine_name" alt="모델명">
									</td>
									<th>사용구분</th>
									<td>
										<select class="form-control" id="s_use_yn" name="s_use_yn">
											<option value="">- 전체 -</option>
											<option value="Y">사용</option>
											<option value="N">미사용</option>
										</select>
									</td>									
									<td>
										<button type="button" onclick="javascript:goSearch()" class="btn btn-important" style="width: 50px;">조회</button>
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
								<button type="button" onclick="javascript:fnDownloadExcel();" class="btn btn-default"><i class="icon-btn-excel inline-btn"></i>엑셀다운로드</button>
							</div>
						</div>
					</div>
<!-- /조회결과 -->
					<div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
					<div class="btn-group mt5">
						<div class="left">
							총 <strong class="text-primary" id="total_cnt">0</strong>건
						</div>	
						<div class="right">
							<button type="button" onclick="goSave()" class="btn btn-info">저장</button>
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