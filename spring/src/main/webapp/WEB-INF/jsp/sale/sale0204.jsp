<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비관리 > 장비통합조회 > null > null
-- 작성자 : 성현우
-- 최초 작성일 : 2020-05-15 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		// 관리부만 볼 수 있는 컬럼 리스트
		var columnListHideExManageOrg = ["mng_cost_amt", "sale_amt", "fe_unit_price", "out_part_unit_price"];

		$(document).ready(function () {
			createAUIGrid();
			fnInit();

			// 입력폼으로 포커스 인
			$("#s_mem_no").focusin(function () {
				$M.clearValue({field: ["s_sale_mem_no"]});
			});
			goSearch();
		});

		// 사용자가 관리부인지
		function isManageOrg() {
			<%--var secureOrgCode = "${SecureUser.org_code}";--%>
			if ("${page.fnc.F00073_001}" == "Y") {
				return true;
			}
			return false;
		}

		function fnInit() {
			if (!isManageOrg()) {
				AUIGrid.hideColumnByDataField(auiGrid, columnListHideExManageOrg);
			}
			// var secureOrgCode = "${SecureUser.org_code}";
			// if(secureOrgCode != "2000") {
				// [15125] "외화단가", "기본출하부품원가" 관리부만 볼 수 있는 항목에 추가 - 김경빈
				// AUIGrid.hideColumnByDataField(auiGrid, ["mng_cost_amt", "sale_amt", "fe_unit_price", "out_part_unit_price"]);
			// }
		}

		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_body_no"];
			$.each(field, function () {
				if (fieldObj.name == this) {
					goSearch();
				}
			});
		}

		// 영업담당 setting
		function fnMyExecFuncName(data) {
			$M.setValue("s_sale_mem_no", data.mem_no);
		}

		// 모델조회
		function fnSettingMachine(data) {
			$M.setValue("s_machine_name", data.machine_name);
		}

		// 조회
		function goSearch() {
			var frm = document.main_form;
			//validationcheck
			if ($M.validation(frm,
					{field: ["s_start_dt", "s_end_dt"]}) == false) {
				return;
			}
			
			if ($M.getValue("s_date_type") == "" && $M.getValue("s_machine_status_cd") == "") {
				alert("[기간종류, 출고유형] 중 하나는 필수입니다.");
				return false;
			}
			

			var param = {
				"s_date_type": $M.getValue("s_date_type"),
				"s_start_dt": $M.getValue("s_start_dt"),
				"s_end_dt": $M.getValue("s_end_dt"),
				"s_machine_status_cd_str": $M.getValue("s_machine_status_cd"),
				"s_maker_cd": $M.getValue("s_maker_cd"),
				"s_machine_name": $M.getValue("s_machine_name"),
				"s_machine_out_ye" : $M.getValue("s_machine_out_ye"),
				"s_sale_mem_no": $M.getValue("s_sale_mem_no"),
				"s_in_org_code": $M.getValue("s_in_org_code"),
				"s_body_no": $M.getValue("s_body_no"),
				"s_tax_type_cd": $M.getValue("s_tax_type_cd")
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: "GET"},
					function (result) {
						if (result.success) {
							AUIGrid.setGridData(auiGrid, result.list);
							$("#total_cnt").html(result.total_cnt);
						}
					}
			);
		}

		// 보유장비현황 팝업 호출
		function goMachineDetail() {
			var param = {
				"s_machine_status_cd_str": $M.getValue("s_machine_status_cd"),
				"s_maker_cd": $M.getValue("s_maker_cd"),
				"s_machine_name": $M.getValue("s_machine_name"),
				"s_sale_mem_no": $M.getValue("s_sale_mem_no"),
				"s_body_no": $M.getValue("s_body_no")
			};

			var popupOption = "scrollbars=yes, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=900, height=450, left=0, top=0";
			$M.goNextPage('/sale/sale0204p02', $M.toGetParam(param), {popupStatus: popupOption});
		}

		// 장비별집계조회 팝업 호출
		function goTotalSearchByMachine() {
			if ($M.getValue("s_date_type") == "") {
				alert("검색 기준을 선택해 주세요.");
				return;
			}

			var param = {
				"s_date_type": $M.getValue("s_date_type"),
				"s_start_dt": $M.getValue("s_start_dt"),
				"s_end_dt": $M.getValue("s_end_dt"),
				"s_machine_status_cd_str": $M.getValue("s_machine_status_cd"),
				"s_maker_cd": $M.getValue("s_maker_cd"),
				"s_machine_name": $M.getValue("s_machine_name"),
				"s_sale_mem_no": $M.getValue("s_sale_mem_no"),
				"s_in_org_code": $M.getValue("s_in_org_code"),
				"s_body_no": $M.getValue("s_body_no"),
				"s_tax_type_cd": $M.getValue("s_tax_type_cd")
			};

			var popupOption = "scrollbars=yes, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=500, height=450, left=0, top=0";
			$M.goNextPage('/sale/sale0204p03', $M.toGetParam(param), {popupStatus: popupOption});
		}

		// 액셀다운로드
		function fnDownloadExcel() {
			// [15131] 관리부 사용자가 아닐 경우, 엑셀 다운로드 시 관리부만 볼 수 있는 컬럼 다운로드 제외
			if (!isManageOrg()) {
				var exportProps = {
					exceptColumnFields : columnListHideExManageOrg
				};
			}
			fnExportExcel(auiGrid, "장비통합조회", exportProps);
		}

		function createAUIGrid() {
			var gridPros = {
				rowIdField: "row",
				showRowNumColumn: true,
				// 고정칼럼 카운트 지정
				// fixedColumnCount : 3,
				editable: false,
				enableMovingColumn: true
			};
			var columnLayout = [
				{
					headerText: "차대번호",
					dataField: "body_no",
					width : "150",
					minWidth : "140",
					style: "aui-center aui-popup"
				},
				{
					headerText: "엔진번호",
					dataField: "engine_no",
					width : "80",
					minWidth : "70",
					style: "aui-center"
				},
				{
					headerText: "모델명",
					dataField: "machine_name",
					width : "80",
					minWidth : "70",
					style: "aui-center",
				},
				{
					headerText: "메이커",
					dataField: "maker_name",
					width : "80",
					minWidth : "70",
					style: "aui-center",
					visible: false
				},
				{
					headerText: "장비구분",
					dataField: "machine_out_ye_name",
					width : "80",
					minWidth : "70",
					style: "aui-center"
				},
				{
					headerText: "선적일",
					dataField: "ship_dt",
					width : "80",
					minWidth : "70",
					dataType: "date",
					formatString: "yy-mm-dd"
				},
				{
					headerText: "통관일",
					dataField: "pass_dt",
					width : "80",
					minWidth : "70",
					dataType: "date",
					formatString: "yy-mm-dd"
				},
				{
					headerText: "입고일",
					dataField: "in_dt",
					width : "80",
					minWidth : "70",
					dataType: "date",
					formatString: "yy-mm-dd"
				},
				{
					headerText: "고객명",
					dataField: "cust_name",
					width : "100",
					minWidth : "90",
					style: "aui-center"
				},
				{
					headerText: "마케팅담당",
					dataField: "sale_mem_name",
					width : "80",
					minWidth : "70",
					style: "aui-center"
				},
				{
					headerText: "사업자명",
					dataField: "breg_name",
					width : "100",
					minWidth : "90",
					style: "aui-center"
				},
				{
					headerText: "보유센터",
					dataField: "in_org_name",
					width : "80",
					minWidth : "70"
				},
				{ // [15125] "외화단가", "기본출하부품 원가" 컬럼 추가 - 김경빈
					headerText: "외화단가",
					dataField: "fe_unit_price",
					width : "80",
					minWidth : "70",
					dataType : "numeric",
					formatString : "#,##0",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == 0 ? "" : $M.setComma(value);
					}
				},
				{
					headerText: "기본출하부품 원가",
					dataField: "out_part_unit_price",
					width : "120",
					minWidth : "70",
					dataType : "numeric",
					formatString : "#,##0"
				},
				{
					headerText: "판매일",
					dataField: "sale_dt",
					dataType: "date",
					width : "80",
					minWidth : "70",
					formatString: "yy-mm-dd"
				},
				{
					headerText: "계산서일",
					dataField: "taxbill_dt",
					dataType: "date",
					width : "80",
					minWidth : "70",
					formatString: "yy-mm-dd"
				},
				{
					headerText: "계산서구분",
					dataField: "tax_type_name",
					width : "80",
					minWidth : "70",
					style: "aui-center"
				},
				{
					headerText: "계약번호",
					dataField: "machine_doc_no",
					width : "80",
					minWidth : "70",
					style: "aui-center",
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return value.substring(4, 16);
					}
				},
				{
					headerText: "관리원가",
					dataField: "mng_cost_amt",
					style: "aui-right",
					dataType: "numeric",
					width : "80",
					minWidth : "70",
					formatString: "#,##0"
				},
				{
					headerText: "판매가",
					dataField: "sale_amt",
					style: "aui-right",
					dataType: "numeric",
					width : "80",
					minWidth : "70",
					formatString: "#,##0",
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						return value == 0 ? "" : $M.setComma(value);
					}
				},
				{
					headerText: "구분",
					dataField: "machine_status_name",
					width : "60",
					minWidth : "50",
					style: "aui-center"
				},
				{
					headerText: "상태",
					dataField: "machine_out_pos_status_name",
					width : "60",
					minWidth : "50",
					style: "aui-center"
				},
				{
					headerText: "비고",
					dataField: "remark",
					width : "120",
					minWidth : "110",
					style: "aui-left"
				},
				{
					headerText: "장비일련번호",
					dataField: "machine_seq",
					visible: false
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			$("#auiGrid").resize();

			AUIGrid.bind(auiGrid, "cellClick", function (event) {
				if (event.dataField == "body_no") {
					// 보낼 데이터
					var params = {
						"s_machine_seq": event.item.machine_seq
					};
					var popupOption = "scrollbars=yes, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1700, height=800, left=0, top=0";
					$M.goNextPage('/sale/sale0205p01', $M.toGetParam(params), {popupStatus: popupOption});
				}
			});
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
<%--					<style>.search-wrap th, .search-wrap td {border: 0px solid #ff0000;}</style>--%>
					<!-- 검색영역 -->
					<div class="search-wrap">
						<table class="table table-fixed">
							<colgroup>
								<col width="100px">
								<col width="180px">
								<col width="80px">
								<col width="60px">
								<col width="150px">
								<col width="110px">
								<col width="120px">
								<col width="85px">
								<col width="180px">
								<col width="50px">
								<col width="100px">
								<col width="120px">
							</colgroup>
							<tbody>
							<tr>
								<td>
									<select name="s_date_type" id="s_date_type" class="form-control width100px">
										<option value="">- 전체 -</option>
										<option value="ship_dt">선적일</option>
										<option value="sale_dt">판매일자</option>
										<option value="pass_dt">통관일자</option>
										<option value="taxbill_dt">계산서일</option>
										<option value="in_dt">입고일</option>
									</select>
								</td>
								<td colspan="2">
									<div class="form-row inline-pd">
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 essential-bg calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" alt="시작일" value="${searchDtMap.s_start_dt}">
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 essential-bg calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="종료일" value="${searchDtMap.s_end_dt}">
											</div>
										</div>

										<!-- <details data-popover="up">

                                    	</details> -->
										<jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
											<jsp:param name="st_field_name" value="s_start_dt"/>
											<jsp:param name="ed_field_name" value="s_end_dt"/>
											<jsp:param name="click_exec_yn" value="Y"/>
											<jsp:param name="exec_func_name" value="goSearch();"/>
										</jsp:include>
									</div>
								</td>
								<th>차대번호</th>
								<td>
									<div class="icon-btn-cancel-wrap ">
										<input type="text" class="form-control width240px" id="s_body_no" name="s_body_no">
									</div>
								</td>
								<th>메이커</th>
								<td>
									<select id="s_maker_cd" name="s_maker_cd" class="form-control">
										<option value="">- 전체 -</option>
										<option value="27">얀마</option>
										<option value="02">겔</option>
										<option value="68">마니또</option>
										<option value="94">빌트겐</option>
										<option value="101">보겔</option>
										<option value="42">햄</option>
										<option value="21">사카이</option>
										<option value="00">기타</option>
									</select>
								</td>
								<th>모델명</th>
								<td>
									<jsp:include page="/WEB-INF/jsp/common/searchMachine.jsp">
										<jsp:param name="required_field" value="s_machine_name"/>
										<jsp:param name="s_maker_cd" value=""/>
										<jsp:param name="s_machine_type_cd" value=""/>
										<jsp:param name="s_sale_yn" value=""/>
										<jsp:param name="readonly_field" value=""/>
										<jsp:param name="execFuncName" value="fnSettingMachine"/>
									</jsp:include>
								</td>
								<th>장비구분</th>
								<td>
									<select id="s_machine_out_ye" name="s_machine_out_ye" class="form-control">
										<option value="">- 전체 -</option>
										<option value="Y" selected="selected">자사</option>
										<option value="E">타사</option>
									</select>
								</td>
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
								</td>
							</tr>
							<tr>
								<th>마케팅담당</th>
								<td colspan="2">
									<jsp:include page="/WEB-INF/jsp/common/searchMem.jsp">
										<jsp:param name="required_field" value=""/>
										<jsp:param name="s_org_code" value=""/>
										<jsp:param name="s_work_status_cd" value=""/>
										<jsp:param name="readonly_field" value=""/>
										<jsp:param name="execFuncName" value="fnMyExecFuncName"/>
									</jsp:include>
								</td>
								<th>보유센터</th>
								<td>
									<select class="form-control width100px" name="s_in_org_code" id="s_in_org_code">
										<option value="">- 전체 -</option>
										<c:forEach var="list" items="${codeMap['WAREHOUSE']}">
											<option value="${list.code_value}">${list.code_name}</option>
										</c:forEach>
									</select>
								</td>
								<th>계산서구분</th>
								<td>
									<select name="s_tax_type_cd" id="s_tax_type_cd" class="form-control">
										<option value="">- 전체 -</option>
										<option value="Y">정발행</option>
										<option value="N">가발행</option>
										<option value="R">수정세금계산서</option>
									</select>
								</td>
								<th>출고유형</th>
								<td colspan="6">
									<c:forEach items="${codeMap['MACHINE_STATUS']}" var="item">
										<div class="form-check form-check-inline v-align-middle">
											<input type="checkbox" id="${item.code_value}" name="s_machine_status_cd" <c:if test="${item.code_value == '00'}">checked="checked"</c:if> class="form-check-input" value="${item.code_value}">
											<label class="form-check-label" for="${item.code_value}">${item.code_name}</label>
										</div>
									</c:forEach>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /검색영역 -->
					<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>조회내역</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
					<!-- /그리드 타이틀, 컨트롤 영역 -->
					<div style="margin-top: 5px; height: 550px;" id="auiGrid"></div>
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
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>