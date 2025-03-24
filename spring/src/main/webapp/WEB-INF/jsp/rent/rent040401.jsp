<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 렌탈 > 렌탈현황 > 렌탈장비 수요분석 > 고객별 > null
-- 작성자 : 정윤수
-- 최초 작성일 : 2024-01-18 13:36:21
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid;
		var hideList; // 펼침 항목

		$(document).ready(function() {
			$("input:checkbox[id='s_toggle_column']").attr("checked", false);
			createAUIGrid();
			// headerStyle에 aui-fold가 있는 컬럼항목 구하기
			hideList = AUIGrid.getColumnInfoList(auiGrid)
					.filter(obj => obj.headerStyle && obj.headerStyle.includes("aui-fold"))
					.map(obj => obj.dataField);
			// 펼침항목 숨김처리
			AUIGrid.hideColumnByDataField(auiGrid, hideList);
		});
		
		//조회
		function goSearch() {
			var param = {
				"s_year": $M.getValue("s_year"),
				"s_cust_name": $M.getValue("s_cust_name"),
				"s_hp_no": $M.getValue("s_hp_no"),
				"s_breg_name": $M.getValue("s_breg_name"),
				"s_mch_use_cd": $M.getValue("s_mch_use_cd"),
				"s_breg_type_cd": $M.getValue("s_breg_type_cd"),
				"s_machine_yn": $M.getValue("s_machine_yn"),
				"s_center_org_code": $M.getValue("s_center_org_code"),
				"s_masking_yn": $M.getValue("s_masking_yn"),
			};
			$M.goNextPageAjax("/rent/rent040401/search", $M.toGetParam(param), {method: "GET"},
					function (result) {
						if(result.success) {
							// 전체 조회한 경우 조회기간 렌탈이력 컬럼 숨김
							if("" == $M.getValue("s_year")){
								AUIGrid.hideColumnByDataField(auiGrid, ["rent_cnt", "rental_amt"]);
							} else {
								AUIGrid.showColumnByDataField(auiGrid, ["rent_cnt", "rental_amt"]);
							}
							AUIGrid.setGridData(auiGrid, result.list);
							$("#total_cnt").html(result.total_cnt);
							$("#curr_cnt").html(result.list.length);
						};
					}
			);
		}
		// 펼침
		function fnChangeColumn(event) {
			var target = event.target || event.srcElement;
			if (!target)	return;
			var checked = target.checked;
			if (checked) {
				AUIGrid.showColumnByDataField(auiGrid, hideList);
			} else {
				AUIGrid.hideColumnByDataField(auiGrid, hideList);
			}
		}
		
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "렌탈장비 수요분석(고객별)");
		}

		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_cust_name", "s_hp_no", "s_breg_name"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}
		
		// 문자발송
		function fnSms() {
			var items = AUIGrid.getCheckedRowItemsAll(auiGrid);
			if (items.length == 0) {
				alert("체크된 데이터가 없습니다.");
				return false
			}
			var param = {
				'sms_send_type_cd' : "2",
				'req_sendtarger_yn' : "Y"
			}
			openSendSmsPanel($M.toGetParam(param));
		}

		function reqSendTargetList(){
			var items = AUIGrid.getCheckedRowItemsAll(auiGrid);
			if (items.length == 0) {
				alert("체크된 데이터가 없습니다.");
				return false
			}

			var parentTargetList = [];
			for (var i = 0; i < items.length; i++) {
				var obj = new Object();

				obj['phone_no'] = items[i].origin_hp_no;
				obj['receiver_name'] = items[i].origin_cust_name;
				obj['ref_key'] = items[i].cust_no;

				parentTargetList.push(obj);
			}
			return parentTargetList;
		}
		
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				showRowNumColum : true,
				// 체크박스 출력 여부
				showRowCheckColumn : true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				showFooter : true,
				footerPosition : "top",
			};

			var columnLayout = [
				{
					headerText : "고객명",
					dataField : "cust_name",
					width : "100",
					minWidth : "100",
					style : "aui-center aui-popup"
				},
				{
					headerText : "업체명",
					dataField : "breg_name",
					width : "120",
					minWidth : "120",
					style : "aui-center"
				},
				{
					headerText : "휴대폰",
					headerStyle : "aui-fold",
					dataField : "hp_no",
					width : "110",
					minWidth : "110",
					style : "aui-center"
				},
				{
					headerText : "사업자<br>등록구분",
					dataField : "breg_type_name",
					width : "70",
					minWidth : "70",
					style : "aui-center"
				},
				{
					headerText : "장비용도",
					headerStyle : "aui-fold",
					dataField : "mch_use_name",
					width : "70",
					minWidth : "110",
					style : "aui-center"
				},
				{
					headerText : "자사장비<br>보유",
					dataField : "machine_yn",
					width : "60",
					minWidth : "60",
					style : "aui-center",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if (value == "Y") {
							return "보유";
						} else {
							return "미보유";
						}
					},
					styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
						if(value != "Y") {
							return "";
						}
						return "aui-popup"
					},
				},
				{
					headerText : "총 렌탈<br>이력(회)",
					dataField : "total_rent_cnt",
					width : "60",
					minWidth : "60",
					style : "aui-center aui-popup"
				},
				{
					headerText : "조회기간<br>렌탈 이력(회)",
					dataField : "rent_cnt",
					width : "80",
					minWidth : "80",
					style : "aui-center aui-popup"
				},
				{
					headerText : "총 렌탈 이용료",
					dataField : "total_rental_amt",
					width : "120",
					minWidth : "120",
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{
					headerText : "당년 렌탈 이용료",
					dataField : "rental_amt",
					width : "120",
					minWidth : "120",
					style : "aui-right",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{
					headerText : "당년 총<br>임대일수",
					dataField : "day_cnt",
					width : "90",
					minWidth : "90",
					style : "aui-center",
					dataType : "numeric",
					formatString : "#,###",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
						if(value == ""){
							return "";
						}else {
							return AUIGrid.formatNumber(value, "#,##0") + "(일)";
						}
					},
				},
				{
					headerText : "당년 기간별 이용 비율",
					dataField : "",
					children : [
						{
							headerText : "7일 이하",
							dataField : "day7_cnt",
							style : "aui-center",
							width : "60",
							minWidth : "60",
						},
						{
							headerText : "비율(%)",
							dataField : "day7_rate",
							style : "aui-center",
							width : "60",
							minWidth : "60",
							labelFunction : window.parent.percentageLabelFunction
						},
						{
							headerText : "8~31일",
							dataField : "day31_cnt",
							width : "60",
							minWidth : "60",
						},
						{
							headerText : "비율(%)",
							dataField : "day31_rate",
							width : "60",
							minWidth : "60",
							labelFunction : window.parent.percentageLabelFunction
						},
						{
							headerText : "32일 이상",
							dataField : "day32_cnt",
							width : "60",
							minWidth : "60",
						},
						{
							headerText : "비율(%)",
							dataField : "day32_rate",
							width : "60",
							minWidth : "60",
							labelFunction : window.parent.percentageLabelFunction
						},
					]
				},
				{
					headerText : "지역명",
					dataField : "area_disp",
					width : "70",
					minWidth : "70",
					style : "aui-center"
				},
				{
					headerText : "담당센터",
					dataField : "center_org_name",
					width : "60",
					minWidth : "60",
					style : "aui-center"
				},
				{
					headerText : "주소",
					headerStyle : "aui-fold",
					dataField : "addr",
					width : "250",
					minWidth : "250",
					style : "aui-center"
				},
				{
					headerText : "개인정보 수집 동의",
					headerStyle : "aui-fold",
					dataField : "",
					children : [
						{
							headerText : "수집",
							headerStyle : "aui-fold",
							dataField : "personal_yn",
							style : "aui-center",
							width : "50",
							minWidth : "50",
						},
						{
							headerText : "제3자",
							headerStyle : "aui-fold",
							dataField : "three_yn",
							style : "aui-center",
							width : "50",
							minWidth : "50",
						},
						{
							headerText : "마케팅",
							headerStyle : "aui-fold",
							dataField : "marketing_yn",
							width : "50",
							minWidth : "50",
						},
					]
				},
				{
					dataField : "cust_no",
					visible : false
				},
				{
					dataField : "breg_no",
					visible : false
				},
				{
					dataField : "breg_type_cd",
					visible : false
				},
				{
					dataField : "mch_use_cd",
					visible : false
				},
				{
					dataField : "center_org_code",
					visible : false
				},
			];
			// 푸터 설정
			var footerLayout = [
				{
					labelText : "합계",
					positionField : "cust_name"
				},
				{
					dataField: "total_rent_cnt",
					positionField: "total_rent_cnt",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-center aui-footer aui-popup"
				},
				{
					dataField: "rent_cnt",
					positionField: "rent_cnt",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-center aui-footer aui-popup"
				},
				{
					dataField: "total_rental_amt",
					positionField: "total_rental_amt",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"
				},
				{
					dataField: "rental_amt",
					positionField: "rental_amt",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-right aui-footer"
				},
				{
					dataField: "day_cnt",
					positionField: "day_cnt",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-center aui-footer",
					labelFunction : function(value, columnValues, footerValues) {
						if(value == ""){
							return "";
						}else {
							return AUIGrid.formatNumber(value, "#,##0") + "(일)";
						}
					},
				},
				{
					dataField: "day7_cnt",
					positionField: "day7_cnt",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-center aui-footer"
				},
				{
					dataField: "day7_rate",
					positionField: "day7_rate",
					// operation: "SUM",
					formatString : "#,##0",
					style: "aui-center aui-footer",
					labelFunction : function(value, columnValues, footerValues) {

						return !footerValues[6] / footerValues[2] * 100 ? "" : Math.round(footerValues[6] / footerValues[2] * 100) + "%";
					},
				},
				{
					dataField: "day31_cnt",
					positionField: "day31_cnt",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-center aui-footer"
				},
				{
					dataField: "day31_rate",
					positionField: "day31_rate",
					// operation: "SUM",
					formatString : "#,##0",
					style: "aui-center aui-footer",
					labelFunction : function(value, columnValues, footerValues) {

						return !footerValues[8] / footerValues[2] * 100 ? "" : Math.round(footerValues[8] / footerValues[2] * 100) + "%";
					},
				},
				{
					dataField: "day32_cnt",
					positionField: "day32_cnt",
					operation: "SUM",
					formatString : "#,##0",
					style: "aui-center aui-footer"
				},
				{
					dataField: "day32_rate",
					positionField: "day32_rate",
					// operation: "SUM",
					formatString : "#,##0",
					style: "aui-center aui-footer",
					labelFunction : function(value, columnValues, footerValues) {

						return !footerValues[10] / footerValues[2] * 100 ? "" : Math.round(footerValues[10] / footerValues[2] * 100) + "%";
					},
				},

			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);

			// 푸터 레이아웃 세팅
			AUIGrid.setFooter(auiGrid, footerLayout);
			AUIGrid.setGridData(auiGrid, []);

			$("#auiGrid").resize();

			AUIGrid.bind(auiGrid, "cellClick", function(event){
				if(event.dataField == "cust_name") {
					var param = {
						cust_no : event.item.cust_no
					}
					var poppupOption = "";
					$M.goNextPage('/cust/cust0102p01', $M.toGetParam(param), {popupStatus : poppupOption});
				}
				if(event.dataField == "machine_yn" && event.item.machine_yn == "Y") {
					var param = {
						cust_no : event.item.cust_no
					}
					openHaveMachineCustPanel($M.toGetParam(param));
				}
				if(event.dataField == "total_rent_cnt") {
					var params = {
						s_cust_no : event.item.cust_no,
						s_mch_use_cd : $M.getValue("s_mch_use_cd")
					};
					var popupOption = "";
					$M.goNextPage('/rent/rent0404p03', $M.toGetParam(params), {popupStatus : popupOption});
				}
				if(event.dataField == "rent_cnt") {
					var params = {
						s_cust_no : event.item.cust_no,
						s_year : $M.getValue("s_year"),
						s_mch_use_cd : $M.getValue("s_mch_use_cd")
					};
					var popupOption = "";
					$M.goNextPage('/rent/rent0404p04', $M.toGetParam(params), {popupStatus : popupOption});
				}
			});
			// 푸터 클릭 bind
			AUIGrid.bind(auiGrid, "footerClick", function(event) {
				if (event.footerIndex == 6 && event.footerValue > 0) {
				var param = {
					s_mch_use_cd : $M.getValue("s_mch_use_cd")
				}

				var popupOption = "";
					$M.goNextPage("/rent/rent0404p01", $M.toGetParam(param), {popupStatus : popupOption});
				}
				if (event.footerIndex == 7 && event.footerValue > 0) {
					var param = {
						"s_year" 			: $M.getValue("s_year"),
						s_mch_use_cd : $M.getValue("s_mch_use_cd")
					}

					var popupOption = "";
					$M.goNextPage("/rent/rent0404p02", $M.toGetParam(param), {popupStatus : popupOption});
				}
			});
		}

	</script>
</head>
<body style="background : #fff">
<form id="main_form" name="main_form">
	<div class="layout-box">

		<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
				<!-- /메인 타이틀 -->
				<div class="contents">
					<!-- 검색영역 -->
					<div class="search-wrap mt10">
						<table class="table">
							<colgroup>
								<col width="70px">
								<col width="80px">
								<col width="50px">
								<col width="100px">
								<col width="50px">
								<col width="100px">
								<col width="50px">
								<col width="100px">
								<col width="60px">
								<col width="100px">
								<col width="90px">
								<col width="100px">
								<col width="80px">
								<col width="100px">
								<col width="60px">
								<col width="100px">
								<col width="*">
							</colgroup>
							<tbody>
							<tr>
								<th>조회기간</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col width80px">
											<select class="form-control" id="s_year" name="s_year">
												<option value="">- 전체 -</option>
												<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
													<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}"/>
													<option value="${year_option}" <c:if test="${year_option eq inputParam.s_current_year}">selected</c:if>>${year_option}년</option>
												</c:forEach>
											</select>
										</div>
									</div>
								</td>
								<th>고객명</th>
								<td>
									<div class="icon-btn-cancel-wrap">
										<input type="text" class="form-control" id="s_cust_name" name="s_cust_name" alt="고객명">

									</div>
								</td>
								<th>휴대폰</th>
								<td>
									<div class="icon-btn-cancel-wrap">
										<input type="text" class="form-control" placeholder="-없이 숫자만" id="s_hp_no" name="s_hp_no" alt="휴대폰">

									</div>
								</td>
								<th>업체명</th>
								<td>
									<div class="icon-btn-cancel-wrap">
										<input type="text" class="form-control" id="s_breg_name" name="s_breg_name">
									</div>
								</td>
								<th>장비용도</th>
								<td>
									<select class="form-control" id="s_mch_use_cd" name="s_mch_use_cd">
										<option value="">- 전체 -</option>
										<c:forEach var="item" items="${codeMap['MCH_USE']}">
											<option value="${item.code_value}">${item.code_name}</option>
										</c:forEach>
									</select>
								</td>
								<th>사업자등록구분</th>
								<td>
									<select class="form-control" id="s_breg_type_cd" name="s_breg_type_cd">
										<option value="">- 전체 -</option>
										<c:forEach var="item" items="${codeMap['BREG_TYPE']}">
											<option value="${item.code_value}">${item.code_name}</option>
										</c:forEach>
									</select>
								</td>
								<th>장비보유여부</th>
								<td>
									<select class="form-control" id="s_machine_yn" name="s_machine_yn">
										<option value="">- 전체 -</option>
										<option value="Y">보유</option>
										<option value="N">미보유</option>
									</select>
								</td>
								<th>담당센터</th>
								<td>
									<select class="form-control" name="s_center_org_code">
										<option value="">- 전체 -</option>
										<c:forEach items="${orgCenterList}" var="item">
											<option value="${item.org_code}" <c:if test="${item.org_code eq SecureUser.org_code}">selected="selected"</c:if>>${item.org_name}</option>
										</c:forEach>
									</select>
								</td>
								<td class="">
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /검색영역 -->
					<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<div class="form-check form-check-inline">
								<c:if test="${page.add.POS_UNMASKING eq 'Y'}">
									
										<input  class="form-check-input"  type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
										<label  class="form-check-input"  for="s_masking_yn" >마스킹 적용</label>
								</c:if>
								<label for="s_toggle_column">
									<input type="checkbox" id="s_toggle_column" onclick="fnChangeColumn(event)">펼침 
								</label>
								</div>
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>

							</div>
						</div>
					</div>
					<!-- /그리드 타이틀, 컨트롤 영역 -->

					<div id="auiGrid" style="margin-top: 5px; height: 555px; width: 100%;"></div>

					<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							총 <strong id="total_cnt" class="text-primary">0</strong>건
						</div>
					</div>
					<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>

			</div>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>