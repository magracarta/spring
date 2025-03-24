<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 공통 > 메인 > 문자발송 > null > 홍보파일참조
-- 작성자 : 박예진
-- 최초 작성일 : 2019-12-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		var seqList;
		$(document).ready(function() {
			createAUIGrid();
		});
		
			//조회
		function goSearch() { 
			var param = {
					"s_title" : $M.getValue("s_title"),
					"s_machine_name" : $M.getValue("s_machine_name"),
					"s_sort_key" : "reg_date",
					"s_sort_method" : "desc"
			}; 
	
			$M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGrid, result.list);
						$("#total_cnt").html(result.total_cnt);
						seqList = result.seqList;
					};
				}
			)
		}
			
		function enter(fieldObj) {
			var field = [ "s_title", "s_machine_name" ];
			$.each(field, function() {
				if (fieldObj.name == this) {
					goSearch();
				};
			});
		}
		
		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "sms_attach_seq",
				rowHeight	: 150,
			};
			var columnLayout = [
				{ 
					dataField : "sms_attach_seq",
					visible : false
				},
				{
					headerText : "이미지",
					dataField : "sms_file_seq_1",
					width : 180,
					renderer : {
						type : "ImageRenderer",
						imgHeight : 150, // 이미지 높이, 지정하지 않으면 rowHeight에 맞게 자동 조절되지만 빠른 렌더링을 위해 설정을 추천합니다.
						altField : "file_name_1" // alt(title) 속성에 삽입될 필드명, 툴팁으로 출력됨
					}
				},
				{ 
					dataField : "sms_file_seq_2",
					renderer : {
						type : "ImageRenderer",
						imgHeight : 150, // 이미지 높이, 지정하지 않으면 rowHeight에 맞게 자동 조절되지만 빠른 렌더링을 위해 설정을 추천합니다.
						altField : "file_name_2" // alt(title) 속성에 삽입될 필드명, 툴팁으로 출력됨
					},
					visible : false
				},
				{ 
					dataField : "sms_file_seq_3",
					renderer : {
						type : "ImageRenderer",
						imgHeight : 150, // 이미지 높이, 지정하지 않으면 rowHeight에 맞게 자동 조절되지만 빠른 렌더링을 위해 설정을 추천합니다.
						altField : "file_name_3" // alt(title) 속성에 삽입될 필드명, 툴팁으로 출력됨
					},
					visible : false
				},
				{ 
					dataField : "file_size_1",
					visible : false
				},
				{ 
					dataField : "file_size_2",
					visible : false
				},
				{ 
					dataField : "file_size_3",
					visible : false
				},
				{ 
					dataField : "file_ext_1",
					visible : false
				},
				{ 
					dataField : "file_ext_2",
					visible : false
				},
				{ 
					dataField : "file_ext_3",
					visible : false
				},
				{ 
					dataField : "file_seq_1",
					visible : false
				},
				{ 
					dataField : "file_seq_2",
					visible : false
				},
				{ 
					dataField : "file_seq_3",
					visible : false
				},
				{ 
					headerText : "모델", 
					dataField : "machine_name",
					width : "25%",
					style : "aui-center"
				},
				{
					headerText : "제목", 
					dataField : "title", 
					style : "aui-left"
				}
			];
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				var tempArr = [];
				// 이미지 클릭 시
				if(event.dataField == "sms_file_seq_1") {
					// sms_file_seq 리스트 가공
					for(var seq in seqList) {
						if(seq == event.item["sms_attach_seq"]) {
							tempArr = seqList[seq];
						}
					}
					var itemArr = [];
					// 라이브러리 형식으로 가공
					for(var sms_file in tempArr[0] ) {
						var smsArr = {"src" : tempArr[0][sms_file]};
						itemArr.push(smsArr);
					}
					if(itemArr == "") {
						alert("이미지가 존재하지 않습니다.");
						return false;
					}
					// 이미지 미리보기 라이브러리
					$.magnificPopup.open({
						closeOnContentClick: true,
						closeBtnInside: true,
						fixedContentPos: true,
						mainClass: 'mfp-no-margins mfp-with-zoom',
					    items:itemArr
						,
					    gallery: {
					      enabled: true,
			              navigateByImgClick: true,
					    },
					    image: {
							verticalFit: true,
							tError: '이미지를 불러오는데 실패 하였습니다.'
						},
					    type: 'image'
					});
					 $(".mfp-close").attr('id','magnific-btn-close');
			       	 $("#magnific-btn-close").css({
			            display: "block"
			        });
				} else {
					// Row행 클릭 시 반영
					try{
						opener.${inputParam.parent_js_name}(event.item);
						window.close();
					} catch(e) {
						alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
					}
				} 
			});	
		}
		
		//팝업 끄기
		function fnClose() {
			window.close(); 
		}
		
	</script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
<!-- 팝업 -->
    <div class="popup-wrap width-100per">
<!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
<!-- /타이틀영역 -->
        <div class="content-wrap" style="padding-bottom:0px;">	  
<!-- 검색조건 -->
			<div class="search-wrap">
				<table class="table">
					<colgroup>
						<col width="50px">
						<col width="100px">
						<col width="50px">
						<col width="120px">
						<col width="">
					</colgroup>
					<tbody>
						<tr>
							<th>모델</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" class="form-control" id="s_machine_name" name="s_machine_name">
								</div>
							</td>
							<th>제목</th>
							<td>
								<div class="icon-btn-cancel-wrap">
									<input type="text" class="form-control" id="s_title" name="s_title">
								</div>
							</td>
							<td><button type="button" class="btn btn-important" style="width: 70px;" onclick="javascript:goSearch();">조회</button></td>			
						</tr>
					</tbody>
				</table>
			</div>
<!-- /검색조건 -->
<!-- 검색결과 -->
			<div id="auiGrid" style="margin-top: 5px; height: 465px;"></div>
			<div class="btn-group mt5">
					<div class="left">
						총 <strong class="text-primary" id="total_cnt">0</strong>건
					</div>		
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>				
				</div>
<!-- /검색결과 -->
        </div>
    </div>
<!-- /팝업 -->
</form>
</body>
</html>