<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 고품관리 > 고품관리 > 고품결재등록 > 고품 추가
-- 작성자 : 정재호
-- 최초 작성일 : 2022-09-14 14:09:45
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var auiGrid; // 그리드

		// 전체 체크 버튼을 1번이라도 클릭했는지
		// - false : 1번도 클릭 안함
		// - true  : 1번이라도 클릭 했음
		var isClickedAllCheckBtn = false;

		// 체크가 눌렸던 로우행
		var checkedRowIndexArr = new Set();

		$(document).ready(function () {
			createAUIGrid();
			goSearch();
		});

		function clearCheckInfo() {
			isClickedAllCheckBtn = false;
			checkedRowIndexArr.clear();
		};

		// 절반정보 그리드 생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField: "rownum", // 행 구별 필드명 지정
				showRowNumColumn: true, // 행 번호 출력 여부
				displayTreeOpen: true, // 최초 보여질 때 모두 열린 상태로 출력 여부
				// rowCheckDependingTree : true, // 부모-자식 간의 관계에 따라 체크박스를 표현
				showRowAllCheckBox : true, // 전체선택 체크박스 표시 여부
				showRowCheckColumn : true, // 엑스트라 체크박스 출력 여부
				treeColumnIndex: 6,
				editable: true,
			};

			var columnLayout = [
				{
					headerText: "관리번호",
					dataField: "job_report_no",
					width: "80",
					minWidth: "70",
					style: "aui-center",
					editable: false,
					styleFunction: function (rowIndex, columnIndex, value, headerText, item, dataField) {
						if (item.job_report_no_depth == "1") {
							return "aui-popup";
						} else {
							return null;
						}
					},
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						if (item.job_report_no_depth == "1") {
							return value.substring(4, 16);
						} else {
							return "";
						}
					}
				},
				{
					headerText: "뎁스",
					dataField: "job_report_no_depth",
					visible: false
				},
				{
					headerText: "정비일자",
					dataField: "job_dt",
					dataType: "date",
					formatString: "yy-mm-dd",
					width: "70",
					minWidth: "60",
					style: "aui-center",
					editable: false,
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						if (item.job_report_no_depth == "1") {
							return $M.formatDate($M.toDate(value)).substr(2);
						} else {
							return "";
						}
					}
				},
				{
					headerText: "부서",
					dataField: "org_name",
					width: "70",
					minWidth: "60",
					style: "aui-center",
					editable: false,
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						if (item.job_report_no_depth == "1") {
							return value;
						} else {
							return "";
						}
					}
				},
				{
					headerText: "부서코드",
					dataField: "org_code",
					visible: false
				},
				{
					headerText: "고객명",
					dataField: "cust_name",
					width: "150",
					minWidth: "140",
					style: "aui-center",
					editable: false,
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						if (item.job_report_no_depth == "1") {
							return value;
						} else {
							return "";
						}
					}
				},
				{
					headerText: "모델명",
					dataField: "machine_name",
					width: "100",
					minWidth: "140",
					style: "aui-left",
					editable: false,
					labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
						if (item.job_report_no_depth == "1") {
							return value;
						} else {
							return "";
						}
					}
				},
				{
					headerText: '사용부품',
					dataField: "use_part",
					children: [
						{
							headerText: "부품번호",
							dataField: "part_no",
							width: "150",
							minWidth: "140",
							style: "aui-left",
							editable: false,
						},
						{
							headerText: "부품명",
							dataField: "part_name",
							width: "180",
							minWidth: "170",
							style: "aui-left",
							editable: false,
						},
						{
							headerText: "고장부위",
							dataField: "old_part_trouble",
							width: "260",
							minWidth: "250",
							style: "aui-editable",
						},
						{
							headerText: "수량",
							dataField: "qty",
							width: "50",
							minWidth: "40",
							style: "aui-center",
							editable: false,
						},
						{
							headerText: "처리상태",
							dataField: "old_part_proc_status_name",
							width: "80",
							minWidth: "70",
							style: "aui-center",
							editable: false,
						},
						{
							headerText: "처리상태코드",
							dataField: "old_part_proc_status_cd",
							visible: false
						},
					]
				},
			]

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);

			// ready 이벤트 바인딩
			AUIGrid.bind(auiGrid, "ready", function( event ) {
				var gridData = AUIGrid.getGridData(auiGrid);
				if(gridData.length == 0) return;
				setCheckedRowsByIds(gridData);
			});

			// 셀 클릭 이벥트
			AUIGrid.bind(auiGrid, "cellClick", function (event) {
				if(event.dataField == "old_part_trouble") {
					checkedRowIndexArr.add(event.rowIndex);
				}

				if (event.dataField == "job_report_no" && event.item.job_report_no_depth == "1") {
					var params = {
						"s_job_report_no": event.item.job_report_no
					};
					var popupOption = "scrollbars=yes, resizable-1, mebubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=300, height=200, left=0, top=0";
					$M.goNextPage('/serv/serv0101p01', $M.toGetParam(params), {popupStatus: popupOption});
				}
			});

			// 1개의 로우 체크 버튼 이벤트
			AUIGrid.bind(auiGrid, "rowCheckClick", function( event ) {
				checkedRowIndexArr.add(event.rowIndex);
			});

			// 전체 체크 버튼 이벤트
			AUIGrid.bind(auiGrid, "rowAllCheckClick", function( checked ) {
				isClickedAllCheckBtn = true;
			});
		}

		// 고품 상태인 영역 체크
		function setCheckedRowsByIds(data) {
			let checkNumArr = [];
			for (let i = 0; i < data.length; i++) {
				if(data[i].old_part_yn == 'Y') checkNumArr.push(i + 1);
			}

			AUIGrid.setCheckedRowsByIds(auiGrid, checkNumArr);
		}

		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_body_no", "s_cust_no"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}

		// 검색
		function goSearch() {
			clearCheckInfo(); // 검색시 체크 상태값 초기화

			var sYearMon = fnSetYearMon($M.getValue("s_year"), $M.getValue("s_month"));
			var param = {
				"s_year_mon": sYearMon,
				"s_cust_name" : $M.getValue("s_cust_no"),
				"s_body_no" : $M.getValue("s_body_no"),
				"s_org_code" : '${inputParam.s_org_code}'
			};

			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'GET'},
					function (result) {
						if (result.success) {
							AUIGrid.setGridData(auiGrid, []);
							AUIGrid.setGridData(auiGrid, result.list);
						}
					}
			);
		}

		// 날짜 Setting
		function fnSetYearMon(year, mon) {
			return year + (mon.length == 1 ? "0" + mon : mon);
		}

		//팝업 닫기
		function fnClose() {
			window.close();
		}

		// 저장
		function goSave() {
			var frm = AUIGrid.getGridData(auiGrid);	// 그리드 데이터
			var checkoutData = AUIGrid.getCheckedRowItems(auiGrid); // 체크된 데이터
			var checkIndexArr = checkoutData.map(data => data.rowIndex); // 체크된 index arr
			var dataArr = []; // 서버에 넘어갈 데이터 Arr

			// 2022-11-18 jsk 부품목록 없으면 저장 불가
			if (checkoutData.length == 0) {
				var partOldNo = "${inputParam.part_old_no}";
				if (partOldNo) {
					// 상세화면-부품목록 없으면 삭제처리
					if (confirm("선택한 부품이 없으면 고품이 삭제됩니다. 삭제하시겠습니까?")) {
						var param = {
							part_old_no: partOldNo,
							appr_job_seq: "${inputParam.appr_job_seq}"
						};
						$M.goNextPageAjax(this_page + "/remove", $M.toGetParam(param), {method: "POST"},
								function (result) {
									if (result.success) {
										alert("처리가 완료되었습니다.");
										opener.fnClose("Y");
										fnClose();
									}
								}
						);
					}
					return false;
				} else {
					// 등록화면-부품목록 없으면 저장 불가
					alert("부품을 선택해주세요.");
					return false;
				}
			}
			// 체크 여부에 따라 고품 상태 YN 변경
			for (let i = 0; i < frm.length; i++) {
				// 전체 클릭 버튼이 눌린적이 없고 && 수정된 셀이 없다면
				if(!isClickedAllCheckBtn && !checkedRowIndexArr.has(i)) continue;

				// 체크된 고품은 Y로 아닌건 N으로 처리
				if(checkIndexArr.indexOf(i) < 0) {
					frm[i].old_part_yn = 'N'
				}
				else {
					frm[i].old_part_yn = 'Y'
				}

				// 필요한 데이터만 뽑아서 리스트
				var temp = {
					"job_report_no" : frm[i].job_report_no,
					"seq_no" : frm[i].seq_no,
					"old_part_yn" : frm[i].old_part_yn,
					"old_part_trouble" : frm[i].old_part_trouble,
				}

				dataArr.push(temp);
			}

			if(dataArr.length == 0) {
				alert("수정된 데이터가 없습니다.");
				return;
			}

			var gridFrom = $M.jsonArrayToForm(dataArr);
			$M.goNextPageAjaxSave(this_page + '/save', gridFrom, {method : 'POST'},
					function(result) {
						if(result.success) {
							// 2022-11-11 jsk 16492 고품추가 팝업 등록/상세 재조회
							if (opener.goSearch) {
								opener.goSearch();
							} else if (opener.fnReload){
								opener.fnReload();
							}
						}
					}
			);
		}
	</script>
</head>
<body class="bg-white class">
<form id="main_form" name="main_form">
	<!-- 팝업 -->
	<div class="popup-wrap width-100per">
		<!-- 타이틀영역 -->
		<div class="main-title">
			<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
		</div>
		<!-- /타이틀영역 -->
		<!-- 컨텐츠 영역 -->
		<div class="content-wrap">
			<!-- 기본 -->
			<div class="search-wrap">
				<table class="table">
					<colgroup>
						<col width="50px">
						<col width="1px">
						<col width="50px">
						<col width="120px">
						<col width="60px">
						<col width="100px">
						<col width="*">
					</colgroup>
					<tbody>
					<tr>
						<th>조회년월</th>
						<td>
							<div class="title-wrap" style="justify-content: unset">
								<select class="form-control mr3" style="width: 70px;" id="s_year" name="s_year">
									<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
										<c:set var="year_option" value="${inputParam.s_current_year - i + 2000}" />
										<option value="${year_option}" <c:if test="${year_option eq inputParam.s_year}">selected</c:if>>${year_option}년</option>
									</c:forEach>
								</select>
								<select class="form-control" style="width: 60px;" id="s_month" name="s_month">
									<c:forEach var="i" begin="1" end="12" step="1">
										<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i eq inputParam.s_month}">selected</c:if>>${i}월</option>
									</c:forEach>
								</select>
							</div>
						</td>
						<th>고객명</th>
						<td>
							<input type="text" class="form-control width120px" id="s_cust_no"
								   name="s_cust_no">
						</td>
						<th>차대번호</th>
						<td>
							<input type="text" class="form-control width120px" id="s_body_no"
								   name="s_body_no">
						</td>
						<td class="">
							<button type="button" class="btn btn-important" style="width: 50px;"
									onclick="javascript:goSearch();">조회
							</button>
						</td>
					</tr>
					</tbody>
				</table>
			</div>
			<!-- /기본 -->
			<div class="title-wrap mt10">
				<h4>조회결과</h4>
				<p class="text-warning mr5">• 정비지시서 상태가 미정산완료, 완료인 데이터 조회</p>
			</div>
			<div id="auiGrid" style="margin-top: 5px; height: 350px; position: relative;"></div>
			<!-- 그리드 서머리, 컨트롤 영역 -->
			<div class="btn-group mt5">
				<div class="right">
					<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp">
						<jsp:param name="pos" value="BOM_R"/>
					</jsp:include>
				</div>
			</div>
			<!-- /그리드 서머리, 컨트롤 영역 -->
		</div>
		<!-- /컨텐츠 영역 -->
	</div>
	<!-- /팝업 -->
</form>
</body>
</html>